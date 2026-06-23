package model;

public class Promotion {
    private int promotionId;
    private int businessId;
    private String title;
    private String description;
    private String startDate;
    private String endDate;
    private boolean isActive;
    private String approvalStatus;

    // 1. Constructor kosong yang betul
    public Promotion() {
    }

    // 2. Constructor untuk set aktif secara terus
    public Promotion(boolean isActive) {
        this.isActive = isActive;
    }

    // --- Getter dan Setter ---

    public int getPromotionId() { return promotionId; }
    public void setPromotionId(int promotionId) { this.promotionId = promotionId; }

    public int getBusinessId() { return businessId; }
    public void setBusinessId(int businessId) { this.businessId = businessId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStartDate() { return startDate; }
    public void setStartDate(String startDate) { this.startDate = startDate; }

    public String getEndDate() { return endDate; }
    public void setEndDate(String endDate) { this.endDate = endDate; }

    // Membetulkan kaedah getter untuk boolean
    public boolean getIsActive() { return isActive; }
    public boolean isIsActive() { return isActive; } // Mengekalkan standard naming convention
    public void setIsActive(boolean isActive) { this.isActive = isActive; }

    public String getApprovalStatus() { return approvalStatus; }
    public void setApprovalStatus(String approvalStatus) { this.approvalStatus = approvalStatus; }
}