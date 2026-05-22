package com.jcaballerod92.financialinquiry.model;

import java.time.LocalDate;

/**
 * DTO representing an account returned by the inquiry API.
 */
public class AccountDto {

    private long accountId;
    private String accountNumber;
    private String accountHolder;
    private String accountStatus;
    private String currency;
    private LocalDate openDate;

    /**
     * Creates the account DTO.
     */
    public AccountDto(long accountId, String accountNumber, String accountHolder, String accountStatus, String currency, LocalDate openDate) {
        this.accountId = accountId;
        this.accountNumber = accountNumber;
        this.accountHolder = accountHolder;
        this.accountStatus = accountStatus;
        this.currency = currency;
        this.openDate = openDate;
    }

    public long getAccountId() { return accountId; }
    public String getAccountNumber() { return accountNumber; }
    public String getAccountHolder() { return accountHolder; }
    public String getAccountStatus() { return accountStatus; }
    public String getCurrency() { return currency; }
    public LocalDate getOpenDate() { return openDate; }

    public void setAccountId(long accountId) { this.accountId = accountId; }
    public void setAccountNumber(String accountNumber) { this.accountNumber = accountNumber; }
    public void setAccountHolder(String accountHolder) { this.accountHolder = accountHolder; }
    public void setAccountStatus(String accountStatus) { this.accountStatus = accountStatus; }
    public void setCurrency(String currency) { this.currency = currency; }
    public void setOpenDate(LocalDate openDate) { this.openDate = openDate; }
}
