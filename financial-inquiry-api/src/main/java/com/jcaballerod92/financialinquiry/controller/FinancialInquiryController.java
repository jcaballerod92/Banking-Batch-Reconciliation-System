package com.jcaballerod92.financialinquiry.controller;

import com.jcaballerod92.financialinquiry.model.AccountDto;
import com.jcaballerod92.financialinquiry.model.ErrorResponse;
import com.jcaballerod92.financialinquiry.model.MovementDto;
import com.jcaballerod92.financialinquiry.service.FinancialInquiryService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Main REST controller for account and movement inquiries.
 * Exposes the public HTTP endpoints of the API.
 */
@RestController
@RequestMapping("/api/inquiries")
public class FinancialInquiryController {

    private final FinancialInquiryService financialInquiryService;

    /**
     * Creates the controller with the required service dependency.
     *
     * @param financialInquiryService business service
     */
    public FinancialInquiryController(FinancialInquiryService financialInquiryService) {
        this.financialInquiryService = financialInquiryService;
    }

    /**
     * Returns account information by account number.
     *
     * @param accountNumber business account number
     * @return account DTO or 404 error
     */
    @GetMapping("/accounts/{accountNumber}")
    public ResponseEntity<?> getAccount(@PathVariable String accountNumber) {
        AccountDto account = financialInquiryService.findAccountByNumber(accountNumber);
        if (account == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse("E404", "Account not found"));
        }
        return ResponseEntity.ok(account);
    }

    /**
     * Returns movement information by transaction identifier.
     *
     * @param transactionId transaction identifier
     * @return movement DTO or 404 error
     */
    @GetMapping("/movements/{transactionId}")
    public ResponseEntity<?> getMovement(@PathVariable String transactionId) {
        MovementDto movement = financialInquiryService.findMovementByTransactionId(transactionId);
        if (movement == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse("E404", "Movement not found"));
        }
        return ResponseEntity.ok(movement);
    }

    /**
     * Returns movements for one account.
     *
     * @param accountNumber business account number
     * @return list of movements
     */
    @GetMapping("/accounts/{accountNumber}/movements")
    public ResponseEntity<List<MovementDto>> getMovementsByAccount(@PathVariable String accountNumber) {
        return ResponseEntity.ok(financialInquiryService.findMovementsByAccount(accountNumber));
    }
}
