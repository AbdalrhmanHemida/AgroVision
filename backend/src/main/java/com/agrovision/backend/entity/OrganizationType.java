package com.agrovision.backend.entity;

/**
 * Represents the different types of users
 */
public enum OrganizationType {
    FARMER("Farmer"),
    RESEARCHER("Researcher"),
    CONSULTANT("Consultant");

    private final String displayName;

    OrganizationType(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }

    @Override
    public String toString() {
        return displayName;
    }
}
