package com.agrovision.backend.service;

import com.agrovision.backend.dto.LoginRequest;
import com.agrovision.backend.dto.LoginResponse;
import com.agrovision.backend.dto.RefreshTokenRequest;
import com.agrovision.backend.dto.RegisterRequest;
import com.agrovision.backend.dto.RegisterResponse;
import com.agrovision.backend.entity.OrganizationType;
import com.agrovision.backend.entity.User;
import com.agrovision.backend.repository.UserRepository;
import com.agrovision.backend.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

/**
 * Authentication Service
 * Handles user registration, login, token refresh, and logout
 */
@Service
@Transactional
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private EmailService emailService;

    @Value("${app.security.max-failed-attempts}")
    private int maxFailedAttempts;

    @Value("${app.security.lockout-duration-minutes}")
    private int lockoutDurationMinutes;

    @Value("${app.email.verification-token-expiration-hours}")
    private int verificationTokenExpirationHours;

    /**
     * Register a new user
     */
    public RegisterResponse register(RegisterRequest request) {
        // Check if email already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        // Create new user
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setOrganizationType(OrganizationType.valueOf(request.getOrganizationType()));
        
        // Set email verification token
        user.setEmailVerificationToken(UUID.randomUUID().toString());
        user.setEmailVerificationExpiresAt(LocalDateTime.now().plusHours(verificationTokenExpirationHours));
        
        // User starts as inactive until email is verified
        user.setIsActive(false);
        user.setIsEmailVerified(false);

        User savedUser = userRepository.save(user);

        // Send verification email
        try {
            emailService.sendEmailVerification(
                savedUser.getEmail(),
                savedUser.getFirstName(),
                savedUser.getEmailVerificationToken()
            );
        } catch (Exception e) {
            // Log error but don't fail registration
            // User can request resend verification email
            throw new RuntimeException("Registration successful but failed to send verification email. Please try requesting a new verification email.");
        }
        
        return RegisterResponse.builder()
                .userId(savedUser.getId())
                .email(savedUser.getEmail())
                .message("Registration successful. Please check your email for verification.")
                .requiresEmailVerification(true)
                .build();
    }

    /**
     * Authenticate user and generate tokens
     */
    public LoginResponse login(LoginRequest request) {
        // Find user by email
        Optional<User> userOptional = userRepository.findByEmail(request.getEmail());
        if (userOptional.isEmpty()) {
            throw new RuntimeException("Invalid email or password");
        }

        User user = userOptional.get();

        // Check if account is locked
        if (user.isAccountLocked()) {
            throw new RuntimeException("Account is temporarily locked due to multiple failed login attempts");
        }

        // Verify password
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            handleFailedLogin(user);
            throw new RuntimeException("Invalid email or password");
        }

        // Check if account is active
        if (!user.getIsActive()) {
            throw new RuntimeException("Account is not active. Please verify your email.");
        }

        // Reset failed attempts on successful login
        if (user.getFailedLoginAttempts() > 0) {
            user.setFailedLoginAttempts(0);
            user.setLockedUntil(null);
        }

        // Update last login
        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        // Generate tokens
        String accessToken = jwtTokenProvider.generateAccessToken(
                user.getId(), 
                user.getEmail(), 
                user.getOrganizationType().name()
        );
        String refreshToken = jwtTokenProvider.generateRefreshToken(user.getId());

        return LoginResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtTokenProvider.getTimeUntilExpiration(accessToken) / 1000) // seconds
                .user(LoginResponse.UserInfo.builder()
                        .id(user.getId())
                        .email(user.getEmail())
                        .firstName(user.getFirstName())
                        .lastName(user.getLastName())
                        .organizationType(user.getOrganizationType().name())
                        .isActive(user.getIsActive())
                        .lastLoginAt(user.getLastLoginAt())
                        .build())
                .build();
    }

    /**
     * Refresh access token using refresh token
     */
    public LoginResponse refreshToken(RefreshTokenRequest request) {
        String refreshToken = request.getRefreshToken();

        // Validate refresh token
        if (!jwtTokenProvider.validateToken(refreshToken)) {
            throw new RuntimeException("Invalid or expired refresh token");
        }

        // Ensure this is a refresh token
        if (!"REFRESH".equals(jwtTokenProvider.getTokenType(refreshToken))) {
            throw new RuntimeException("Invalid token type");
        }

        // Get user from token
        Long userId = jwtTokenProvider.getUserIdFromToken(refreshToken);
        Optional<User> userOptional = userRepository.findById(userId);
        
        if (userOptional.isEmpty()) {
            throw new RuntimeException("User not found");
        }

        User user = userOptional.get();

        // Check if user is still active
        if (!user.getIsActive()) {
            throw new RuntimeException("Account is not active");
        }

        // Generate new tokens
        String newAccessToken = jwtTokenProvider.generateAccessToken(
                user.getId(), 
                user.getEmail(), 
                user.getOrganizationType().name()
        );
        String newRefreshToken = jwtTokenProvider.generateRefreshToken(user.getId());

        return LoginResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtTokenProvider.getTimeUntilExpiration(newAccessToken) / 1000)
                .user(LoginResponse.UserInfo.builder()
                        .id(user.getId())
                        .email(user.getEmail())
                        .firstName(user.getFirstName())
                        .lastName(user.getLastName())
                        .organizationType(user.getOrganizationType().name())
                        .isActive(user.getIsActive())
                        .lastLoginAt(user.getLastLoginAt())
                        .build())
                .build();
    }

    /**
     * Verify email using verification token
     */
    public void verifyEmail(String token) {
        Optional<User> userOptional = userRepository.findByEmailVerificationToken(token);
        if (userOptional.isEmpty()) {
            throw new RuntimeException("Invalid verification token");
        }

        User user = userOptional.get();

        // Check if token is expired
        if (user.isEmailVerificationTokenExpired()) {
            throw new RuntimeException("Verification token has expired");
        }

        // Activate user and clear verification token
        user.setIsEmailVerified(true);
        user.setIsActive(true);
        user.setEmailVerificationToken(null);
        user.setEmailVerificationExpiresAt(null);

        User savedUser = userRepository.save(user);

        // Send welcome email
        try {
            emailService.sendWelcomeEmail(savedUser.getEmail(), savedUser.getFirstName());
        } catch (Exception e) {
            // Don't fail verification if welcome email fails
            // User is still successfully verified
        }
    }

    /**
     * Handle failed login attempt
     */
    private void handleFailedLogin(User user) {
        int attempts = user.getFailedLoginAttempts() + 1;
        user.setFailedLoginAttempts(attempts);

        if (attempts >= maxFailedAttempts) {
            user.setLockedUntil(LocalDateTime.now().plusMinutes(lockoutDurationMinutes));
        }

        userRepository.save(user);
    }
}
