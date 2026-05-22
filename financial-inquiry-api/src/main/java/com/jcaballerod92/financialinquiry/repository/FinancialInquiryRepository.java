package com.jcaballerod92.financialinquiry.repository;

import com.jcaballerod92.financialinquiry.model.AccountDto;
import com.jcaballerod92.financialinquiry.model.MovementDto;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository layer responsible for JDBC data access.
 * Performs account and movement lookups over the H2 database.
 */
@Repository
public class FinancialInquiryRepository {

    private final JdbcTemplate jdbcTemplate;

    /**
     * Creates the repository with the Spring JDBC template.
     *
     * @param jdbcTemplate JDBC helper
     */
    public FinancialInquiryRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * Finds an account using its business account number.
     *
     * @param accountNumber business account number
     * @return account DTO or null
     */
    public AccountDto findAccountByNumber(String accountNumber) {
        String sql = "SELECT ACCOUNT_ID, ACCOUNT_NUMBER, ACCOUNT_HOLDER, ACCOUNT_STATUS, CURRENCY, OPEN_DATE FROM FIN_ACCOUNT WHERE ACCOUNT_NUMBER = ?";
        List<AccountDto> result = jdbcTemplate.query(sql, new Object[]{accountNumber}, (rs, rowNum) ->
                new AccountDto(
                        rs.getLong("ACCOUNT_ID"),
                        rs.getString("ACCOUNT_NUMBER"),
                        rs.getString("ACCOUNT_HOLDER"),
                        rs.getString("ACCOUNT_STATUS"),
                        rs.getString("CURRENCY"),
                        rs.getDate("OPEN_DATE").toLocalDate()
                )
        );
        return result.isEmpty() ? null : result.get(0);
    }

    /**
     * Finds a movement by transaction identifier.
     *
     * @param transactionId transaction identifier
     * @return movement DTO or null
     */
    public MovementDto findMovementByTransactionId(String transactionId) {
        String sql = "SELECT MOVEMENT_ID, TRANSACTION_ID, ACCOUNT_ID, MOVEMENT_DATE, MOVEMENT_TYPE, AMOUNT, CURRENCY, REFERENCE, CHANNEL, SOURCE_SYSTEM FROM FIN_MOVEMENT WHERE TRANSACTION_ID = ?";
        List<MovementDto> result = jdbcTemplate.query(sql, new Object[]{transactionId}, (rs, rowNum) ->
                new MovementDto(
                        rs.getLong("MOVEMENT_ID"),
                        rs.getString("TRANSACTION_ID"),
                        rs.getLong("ACCOUNT_ID"),
                        rs.getDate("MOVEMENT_DATE").toLocalDate(),
                        rs.getString("MOVEMENT_TYPE"),
                        rs.getBigDecimal("AMOUNT"),
                        rs.getString("CURRENCY"),
                        rs.getString("REFERENCE"),
                        rs.getString("CHANNEL"),
                        rs.getString("SOURCE_SYSTEM")
                )
        );
        return result.isEmpty() ? null : result.get(0);
    }

    /**
     * Finds all movements linked to one account number.
     *
     * @param accountNumber business account number
     * @return list of movement DTOs
     */
    public List<MovementDto> findMovementsByAccount(String accountNumber) {
        String sql = "SELECT M.MOVEMENT_ID, M.TRANSACTION_ID, M.ACCOUNT_ID, M.MOVEMENT_DATE, M.MOVEMENT_TYPE, M.AMOUNT, M.CURRENCY, M.REFERENCE, M.CHANNEL, M.SOURCE_SYSTEM FROM FIN_MOVEMENT M INNER JOIN FIN_ACCOUNT A ON A.ACCOUNT_ID = M.ACCOUNT_ID WHERE A.ACCOUNT_NUMBER = ? ORDER BY M.MOVEMENT_DATE, M.MOVEMENT_ID";
        return jdbcTemplate.query(sql, new Object[]{accountNumber}, (rs, rowNum) ->
                new MovementDto(
                        rs.getLong("MOVEMENT_ID"),
                        rs.getString("TRANSACTION_ID"),
                        rs.getLong("ACCOUNT_ID"),
                        rs.getDate("MOVEMENT_DATE").toLocalDate(),
                        rs.getString("MOVEMENT_TYPE"),
                        rs.getBigDecimal("AMOUNT"),
                        rs.getString("CURRENCY"),
                        rs.getString("REFERENCE"),
                        rs.getString("CHANNEL"),
                        rs.getString("SOURCE_SYSTEM")
                )
        );
    }
}
