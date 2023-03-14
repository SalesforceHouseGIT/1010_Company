/*
DO NOT CREATE LOGIC INSIDE THIS CLASS
 *THIS CLASS SHALL BE USE AS A DISPATCHER
*/
public with sharing class LeadTriggerHandler {

    //* newRecords is ONLY available for before insert, after insert, before update, after update and after undelete context. NOT IN before delete, after delete, before undelete context.
    //* oldRecords is ONLY available for before update, after update, before delete and after delete context. NOT IN before insert, after insert, before undelete, after undelete context.
    //* newMapRecords is ONLY available for after insert, before update, after update and after undelete context. NOT IN before insert, before delete, after delete, before undelete context.
    //* oldMapRecords is ONLY available for before update, after update, before delete and after delete context. NOT IN before insert, after insert, before undelete, after undelete context.
    
    public static void handleTrigger(List<SObject> newRecords, List<SObject> oldRecords, Map<Id, Lead> newMapRecords, Map<Id, Lead> oldMapRecords, System.TriggerOperation triggerEvent ) {
     
        switch on triggerEvent {
         
            /*when AFTER_INSERT, AFTER_UPDATE {
                
            }*/

            when BEFORE_INSERT, BEFORE_UPDATE {
                //set value on record create/
                if (Trigger.isInsert) {
                    LeadTriggerActions.assignLeadOwner(newRecords);
                } else {
                    LeadTriggerActions.stampDateOfContacted(newMapRecords, oldMapRecords);
                    LeadTriggerActions.resetDaysInContactedField(newMapRecords, oldMapRecords);
                }
            }
            /*when BEFORE_DELETE{
            	//prevent deletion of sensitive data
            }
            when AFTER_DELETE {
                //subsequent deletion of related data
            }
            when else {
                //context for AFTER_UNDELETE
            }*/
        }
    }

}