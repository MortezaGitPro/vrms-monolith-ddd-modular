package com.champsoft.vrms.modules.registration.domain.exception;

public class ExpiryDateMustBeFutureException extends RuntimeException {
    public ExpiryDateMustBeFutureException(String message) { super(message); }
}
