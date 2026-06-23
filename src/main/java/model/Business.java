package model;

public class Business {
    private int businessId;
    private int userId;
    private String businessName;
    private String description;
    private String address;
    private String contactPhone;
    private String operatingHours;
    private String gmapsLink;
    private int categoryId;
    private String image;
    
    // Properti Tambahan untuk Relasi Database Konten
    private String categoryName;
    private String ownerUsername;
    private double avgRating;
    private int totalReviews;

    // Getters and Setters Asal
    public int getBusinessId() { return businessId; }
    public void setBusinessId(int businessId) { this.businessId = businessId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getBusinessName() { return businessName; }
    public void setBusinessName(String businessName) { this.businessName = businessName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getContactPhone() { return contactPhone; }
    public void setContactPhone(String contactPhone) { this.contactPhone = contactPhone; }

    public String getOperatingHours() { return operatingHours; }
    public void setOperatingHours(String operatingHours) { this.operatingHours = operatingHours; }

    public String getGmapsLink() { return gmapsLink; }
    public void setGmapsLink(String gmapsLink) { this.gmapsLink = gmapsLink; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    // Getters and Setters untuk Properti Tambahan Baru
    public String getCategoryName() { return categoryName != null ? categoryName : "General"; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getOwnerUsername() { return ownerUsername != null ? ownerUsername : "-"; }
    public void setOwnerUsername(String ownerUsername) { this.ownerUsername = ownerUsername; }

    public double getAvgRating() { return avgRating; }
    public void setAvgRating(double avgRating) { this.avgRating = avgRating; }

    public int getTotalReviews() { return totalReviews; }
    public void setTotalReviews(int totalReviews) { this.totalReviews = totalReviews; }
}