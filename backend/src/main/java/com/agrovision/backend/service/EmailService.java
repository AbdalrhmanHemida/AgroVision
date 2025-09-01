package com.agrovision.backend.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

/**
 * Email Service for sending various types of emails
 * Handles email verification, password reset, and other notifications
 */
@Service
public class EmailService {

    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);

    @Autowired
    private JavaMailSender mailSender;

    @Autowired
    private TemplateEngine templateEngine;

    @Value("${app.email.from-address}")
    private String fromAddress;

    @Value("${app.email.from-name}")
    private String fromName;

    @Value("${app.frontend.base-url}")
    private String frontendBaseUrl;

    /**
     * Send email verification email to new users
     */
    public void sendEmailVerification(String toEmail, String firstName, String verificationToken) {
        try {
            String subject = "Welcome to AgroVision Pro - Verify Your Email";
            String verificationUrl = frontendBaseUrl + "/auth/verify-email?token=" + verificationToken;

            // Create template context
            Context context = new Context();
            context.setVariable("firstName", firstName);
            context.setVariable("verificationUrl", verificationUrl);
            context.setVariable("frontendBaseUrl", frontendBaseUrl);

            // Process email template
            String htmlContent = templateEngine.process("email/email-verification", context);

            // Send email
            sendHtmlEmail(toEmail, subject, htmlContent);

            logger.info("Email verification sent to: {}", toEmail);

        } catch (Exception e) {
            logger.error("Failed to send email verification to: {}", toEmail, e);
            throw new RuntimeException("Failed to send verification email", e);
        }
    }

    /**
     * Send password reset email
     */
    public void sendPasswordReset(String toEmail, String firstName, String resetToken) {
        try {
            String subject = "AgroVision Pro - Password Reset Request";
            String resetUrl = frontendBaseUrl + "/auth/reset-password?token=" + resetToken;

            // Create template context
            Context context = new Context();
            context.setVariable("firstName", firstName);
            context.setVariable("resetUrl", resetUrl);
            context.setVariable("frontendBaseUrl", frontendBaseUrl);

            // Process email template
            String htmlContent = templateEngine.process("email/password-reset", context);

            // Send email
            sendHtmlEmail(toEmail, subject, htmlContent);

            logger.info("Password reset email sent to: {}", toEmail);

        } catch (Exception e) {
            logger.error("Failed to send password reset email to: {}", toEmail, e);
            throw new RuntimeException("Failed to send password reset email", e);
        }
    }

    /**
     * Send welcome email after successful verification
     */
    public void sendWelcomeEmail(String toEmail, String firstName) {
        try {
            String subject = "Welcome to AgroVision Pro! Your account is now active";

            // Create template context
            Context context = new Context();
            context.setVariable("firstName", firstName);
            context.setVariable("frontendBaseUrl", frontendBaseUrl);

            // Process email template
            String htmlContent = templateEngine.process("email/welcome", context);

            // Send email
            sendHtmlEmail(toEmail, subject, htmlContent);

            logger.info("Welcome email sent to: {}", toEmail);

        } catch (Exception e) {
            logger.error("Failed to send welcome email to: {}", toEmail, e);
            // Don't throw exception for welcome email failure
            logger.warn("Welcome email failed but continuing with verification process");
        }
    }

    /**
     * Generic method to send HTML emails
     */
    private void sendHtmlEmail(String to, String subject, String htmlContent) throws MessagingException {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setFrom(fromAddress, fromName);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlContent, true); // true indicates HTML content

            mailSender.send(message);
        } catch (Exception e) {
            throw new MessagingException("Failed to send HTML email", e);
        }
    }

    /**
     * Send simple text email (fallback method)
     */
    public void sendSimpleEmail(String to, String subject, String text) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, false, "UTF-8");

            helper.setFrom(fromAddress, fromName);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(text, false); // false indicates plain text

            mailSender.send(message);

            logger.info("Simple email sent to: {}", to);

        } catch (Exception e) {
            logger.error("Failed to send simple email to: {}", to, e);
            throw new RuntimeException("Failed to send email", e);
        }
    }
}
