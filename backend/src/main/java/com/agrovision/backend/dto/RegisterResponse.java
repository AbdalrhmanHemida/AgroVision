package com.agrovision.backend.dto;

/**
 * User registration response DTO
 */
public class RegisterResponse {
    
    private Long userId;
    private String email;
    private String message;
    private Boolean requiresEmailVerification;

    // Builder pattern
    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private Long userId;
        private String email;
        private String message;
        private Boolean requiresEmailVerification;

        public Builder userId(Long userId) {
            this.userId = userId;
            return this;
        }

        public Builder email(String email) {
            this.email = email;
            return this;
        }

        public Builder message(String message) {
            this.message = message;
            return this;
        }

        public Builder requiresEmailVerification(Boolean requiresEmailVerification) {
            this.requiresEmailVerification = requiresEmailVerification;
            return this;
        }

        public RegisterResponse build() {
            RegisterResponse response = new RegisterResponse();
            response.userId = this.userId;
            response.email = this.email;
            response.message = this.message;
            response.requiresEmailVerification = this.requiresEmailVerification;
            return response;
        }
    }

    // Constructors
    public RegisterResponse() {}

    // Getters and Setters
    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Boolean getRequiresEmailVerification() {
        return requiresEmailVerification;
    }

    public void setRequiresEmailVerification(Boolean requiresEmailVerification) {
        this.requiresEmailVerification = requiresEmailVerification;
    }
}
