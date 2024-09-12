trigger QuoteLineApprovalEventTrigger on Quote_Line_Approval__e (after insert) {
    QuoteLineApprovalEventTrigger_Handler.onQuoteLineApprovalEventSave(Trigger.new);
}