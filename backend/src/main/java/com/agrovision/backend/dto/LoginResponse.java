package com.agrovision.backend.dto;

import java.time.LocalDateTime;

/**
 * Login response DTO
 */
public class LoginResponse {
    
    private String accessToken;
    private String refreshToken;
    private String tokenType;
    private Long expiresIn; // seconds
    private UserInfo user;

    // Builder pattern
    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private String accessToken;
        private String refreshToken;
        private String tokenType;
        private Long expiresIn;
        private UserInfo user;

        public Builder accessToken(String accessToken) {
            this.accessToken = accessToken;
            return this;
        }

        public Builder refreshToken(String refreshToken) {
            this.refreshToken = refreshToken;
            return this;
        }

        public Builder tokenType(String tokenType) {
            this.tokenType = tokenType;
            return this;
        }

        public Builder expiresIn(Long expiresIn) {
            this.expiresIn = expiresIn;
            return this;
        }

        public Builder user(UserInfo user) {
            this.user = user;
            return this;
        }

        public LoginResponse build() {
            LoginResponse response = new LoginResponse();
            response.accessToken = this.accessToken;
            response.refreshToken = this.refreshToken;
            response.tokenType = this.tokenType;
            response.expiresIn = this.expiresIn;
            response.user = this.user;
            return response;
        }
    }

    // User info nested class
    public static class UserInfo {
        private Long id;
        private String email;
        private String firstName;
        private String lastName;
        private String organizationType;
        private Boolean isActive;
        private LocalDateTime lastLoginAt;

        public static Builder builder() {
            return new Builder();
        }

        public static class Builder {
            private Long id;
            private String email;
            private String firstName;
            private String lastName;
            private String organizationType;
            private Boolean isActive;
            private LocalDateTime lastLoginAt;

            public Builder id(Long id) {
                this.id = id;
                return this;
            }

            public Builder email(String email) {
                this.email = email;
                return this;
            }

            public Builder firstName(String firstName) {
                this.firstName = firstName;
                return this;
            }

            public Builder lastName(String lastName) {
                this.lastName = lastName;
                return this;
            }

            public Builder organizationType(String organizationType) {
                this.organizationType = organizationType;
                return this;
            }

            public Builder isActive(Boolean isActive) {
                this.isActive = isActive;
                return this;
            }

            public Builder lastLoginAt(LocalDateTime lastLoginAt) {
                this.lastLoginAt = lastLoginAt;
                return this;
            }

            public UserInfo build() {
                UserInfo userInfo = new UserInfo();
                userInfo.id = this.id;
                userInfo.email = this.email;
                userInfo.firstName = this.firstName;
                userInfo.lastName = this.lastName;
                userInfo.organizationType = this.organizationType;
                userInfo.isActive = this.isActive;
                userInfo.lastLoginAt = this.lastLoginAt;
                return userInfo;
            }
        }

        // Getters and Setters
        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getFirstName() { return firstName; }
        public void setFirstName(String firstName) { this.firstName = firstName; }
        public String getLastName() { return lastName; }
        public void setLastName(String lastName) { this.lastName = lastName; }
        public String getOrganizationType() { return organizationType; }
        public void setOrganizationType(String organizationType) { this.organizationType = organizationType; }
        public Boolean getIsActive() { return isActive; }
        public void setIsActive(Boolean isActive) { this.isActive = isActive; }
        public LocalDateTime getLastLoginAt() { return lastLoginAt; }
        public void setLastLoginAt(LocalDateTime lastLoginAt) { this.lastLoginAt = lastLoginAt; }
    }

    // Getters and Setters
    public String getAccessToken() { return accessToken; }
    public void setAccessToken(String accessToken) { this.accessToken = accessToken; }
    public String getRefreshToken() { return refreshToken; }
    public void setRefreshToken(String refreshToken) { this.refreshToken = refreshToken; }
    public String getTokenType() { return tokenType; }
    public void setTokenType(String tokenType) { this.tokenType = tokenType; }
    public Long getExpiresIn() { return expiresIn; }
    public void setExpiresIn(Long expiresIn) { this.expiresIn = expiresIn; }
    public UserInfo getUser() { return user; }
    public void setUser(UserInfo user) { this.user = user; }
}
