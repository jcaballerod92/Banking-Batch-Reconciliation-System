package com.jcaballerod92.financialinquiry.service;

import com.jcaballerod92.financialinquiry.model.AccountDto;
import com.jcaballerod92.financialinquiry.model.MovementDto;
import com.jcaballerod92.financialinquiry.repository.FinancialInquiryRepository;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Service layer that orchestrates inquiry use cases.
 * Keeps business logic away from the controller and repository layers.
 */
@Service
public class FinancialInquiryService {

    private final FinancialInquiryRepository repository;

    /**
     * Creates the service with the required repository dependency.
     *
     * @param repository inquiry repository
     */
    public FinancialInquiryService(FinancialInquiryRepository repository) {
        this.repository = repository;
    }

    /**
     * Finds an account by its business account number.
     *
     * @param accountNumber business account number
     * @return account DTO or null when not found
     */
    public AccountDto findAccountByNumber(String accountNumber) {
        return repository.findAccountByNumber(accountNumber);
    }

    /**
     * Finds a movement by transaction identifier.
     *
     * @param transactionId transaction identifier
     * @return movement DTO or null when not found
     */
    public MovementDto findMovementByTransactionId(String transactionId) {
        return repository.findMovementByTransactionId(transactionId);
    }

    /**
     * Finds all movements linked to one account number.
     *
     * @param accountNumber business account number
     * @return list of movements
     */
    public List<MovementDto> findMovementsByAccount(String accountNumber) {
        return repository.findMovementsByAccount(accountNumber);
    }
}
