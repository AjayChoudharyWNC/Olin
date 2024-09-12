/**
 * @description       : 
 * @author            : Arun Mudaliar
 * @group             : 
 * @last modified on  : 10-31-2021
 * @last modified by  : Arun Mudaliar
**/
public without sharing class QuoteLineApprovalHelper {

    @InvocableMethod(label='Submit quote lines for approval' description='Submits the specified quote lines for approval' category='Quote Line')
  	public static void submitForApproval(List<Id> quoteLineIds) {
        SBQQ.TriggerControl.disable();
        for(Id quoteLineId : quoteLineIds) {
            SBAA.ApprovalAPI.submit(quoteLineId, SBAA__Approval__c.Quote_Line__c);
        }
        SBQQ.TriggerControl.enable();
    }
}