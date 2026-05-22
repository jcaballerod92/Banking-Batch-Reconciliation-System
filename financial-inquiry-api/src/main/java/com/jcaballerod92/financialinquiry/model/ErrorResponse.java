package com.jcaballerod92.financialinquiry.model;

/**
 * Standard error payload returned by the API.
 */
public class ErrorResponse {

    private String errorCode;
    private String errorMessage;

    /**
     * Creates an error response.
     */
    public ErrorResponse(String errorCode, String errorMessage) {
        this.errorCode = errorCode;
        this.errorMessage = errorMessage;
    }

    public String getErrorCode() { return errorCode; }
    public String getErrorMessage() { return errorMessage; }
    public void setErrorCode(String errorCode) { this.errorCode = errorCode; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
}
