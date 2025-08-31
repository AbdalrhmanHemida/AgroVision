package com.agrovision.backend.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.agrovision.backend.entity.OrganizationType;
import com.agrovision.backend.entity.User;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

    Optional<User> findByEmailVerificationToken(String token);

    List<User> findByIsActiveTrueAndOrganizationType(OrganizationType organizationType);

    /**
     * Returns users created within the given date range.
     */
    @Query("SELECT u FROM User u WHERE u.createdAt BETWEEN :startDate AND :endDate")
    List<User> findUsersCreatedBetween(@Param("startDate") LocalDateTime startDate,
                                       @Param("endDate") LocalDateTime endDate);

    /**
     * Updates the failed login attempts for the given user.
     * used for account lockout mechanism.
     */
    @Modifying
    @Query("UPDATE User u SET u.failedLoginAttempts = :attempts WHERE u.email = :email")
    void updateFailedLoginAttempts(@Param("email") String email, @Param("attempts") Integer attempts);

    /**
     * Locks a user account until the specified time.
     */
    @Modifying
    @Query("UPDATE User u SET u.lockedUntil = :lockedUntil WHERE u.email = :email")
    void lockUserAccount(@Param("email") String email, @Param("lockedUntil") LocalDateTime lockedUntil);

    /**
     * Updates the last login timestamp for a user.
     */
    @Modifying
    @Query("UPDATE User u SET u.lastLoginAt = :lastLoginAt WHERE u.email = :email")
    void updateLastLoginAt(@Param("email") String email, @Param("lastLoginAt") LocalDateTime lastLoginAt);

    /**
     * Marks a user as verified and active based on email verification token.
     * Returns the number of updated records.
     */
    @Modifying
    @Query("UPDATE User u SET u.isEmailVerified = true, u.isActive = true, " +
           "u.emailVerificationToken = null, u.emailVerificationExpiresAt = null " +
           "WHERE u.emailVerificationToken = :token")
    int verifyEmailByToken(@Param("token") String token);

    /**
     * Finds users with expired email verification tokens that were never verified.
     */
    @Query("SELECT u FROM User u WHERE u.emailVerificationExpiresAt < :now AND u.isEmailVerified = false")
    List<User> findUsersWithExpiredVerificationTokens(@Param("now") LocalDateTime now);

    /**
     * Counts the number of active users in a given organization type.
     */
    @Query("SELECT COUNT(u) FROM User u WHERE u.isActive = true AND u.organizationType = :organizationType")
    Long countActiveUsersByOrganizationType(@Param("organizationType") OrganizationType organizationType);
}
