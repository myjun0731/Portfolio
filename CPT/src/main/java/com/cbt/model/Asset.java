package com.cbt.model;

public class Asset {
    private int assetId;
    private String type;
    private String url;
    private String signedUrl;
    private String license;

    public Asset() {}

    public Asset(int assetId, String type, String url, String signedUrl, String license) {
        this.assetId = assetId;
        this.type = type;
        this.url = url;
        this.signedUrl = signedUrl;
        this.license = license;
    }

    public int getAssetId() {
        return assetId;
    }

    public void setAssetId(int assetId) {
        this.assetId = assetId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getSignedUrl() {
        return signedUrl;
    }

    public void setSignedUrl(String signedUrl) {
        this.signedUrl = signedUrl;
    }

    public String getLicense() {
        return license;
    }

    public void setLicense(String license) {
        this.license = license;
    }
}
