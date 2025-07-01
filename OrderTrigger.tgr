trigger OrderTrigger on Order (
    before update,
    after insert,
    after update,
    after delete,
    after undelete
) {

    // --- VALIDATION du statut (avant mise à jour) ---
    if (Trigger.isBefore && Trigger.isUpdate) {
        OrderService.validateOrderStatusChange(Trigger.new, Trigger.oldMap);
    }

    // --- MISE À JOUR de Account.Active__c ---
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete || Trigger.isUndelete) {
            OrderService.updateAccountActiveFlag(
                Trigger.isDelete ? null : Trigger.newMap,
                Trigger.isInsert || Trigger.isUndelete ? null : Trigger.oldMap,
                Trigger.isInsert,
                Trigger.isUpdate,
                Trigger.isDelete
            );
        }
    }
}