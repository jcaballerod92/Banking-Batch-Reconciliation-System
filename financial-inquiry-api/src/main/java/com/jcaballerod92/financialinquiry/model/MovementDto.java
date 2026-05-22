package com.jcaballerod92.financialinquiry.model;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * DTO representing a movement returned by the inquiry API.
 */
public class MovementDto {

    private long movementId;
    private String transactionId;
    private long accountId;
    private LocalDate movementDate;
    private String movementType;
    private BigDecimal amount;
    private String currency;
    private String reference;
    private String channel;
    private String sourceSystem;

    /**
     * Creates the movement DTO.
     */
    public MovementDto(long movementId, String transactionId, long accountId, LocalDate movementDate, String movementType, BigDecimal amount, String currency, String reference, String channel, String sourceSystem) {
        this.movementId = movementId;
        this.transactionId = transactionId;
        this.accountId = accountId;
        this.movementDate = movementDate;
        this.movementType = movementType;
        this.amount = amount;
        this.currency = currency;
        this.reference = reference;
        this.channel = channel;
        this.sourceSystem = sourceSystem;
    }

    public long getMovementId() { return movementId; }
    public String getTransactionId() { return transactionId; }
    public long getAccountId() { return accountId; }
    public LocalDate getMovementDate() { return movementDate; }
    public String getMovementType() { return movementType; }
    public BigDecimal getAmount() { return amount; }
    public String getCurrency() { return currency; }
    public String getReference() { return reference; }
    public String getChannel() { return channel; }
    public String getSourceSystem() { return sourceSystem; }

    public void setMovementId(long movementId) { this.movementId = movementId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }
    public void setAccountId(long accountId) { this.accountId = accountId; }
    public void setMovementDate(LocalDate movementDate) { this.movementDate = movementDate; }
    public void setMovementType(String movementType) { this.movementType = movementType; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public void setCurrency(String currency) { this.currency = currency; }
    public void setReference(String reference) { this.reference = reference; }
    public void setChannel(String channel) { this.channel = channel; }
    public void setSourceSystem(String sourceSystem) { this.sourceSystem = sourceSystem; }
}
