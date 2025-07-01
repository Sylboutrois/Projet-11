global class BatchReminderForAccountsWithoutOrders implements Database.Batchable<SObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext bc) {
    Set<Id> accountsWithOrders = new Set<Id>();
    for (AggregateResult ar : [
        SELECT Contract.AccountId accId
        FROM Order
        WHERE ContractId != null AND Contract.AccountId != null
        GROUP BY Contract.AccountId
    ]) {
        accountsWithOrders.add((Id) ar.get('accId'));
    }

    // Construction de la requête dynamique
    String query = 'SELECT Id, Name, OwnerId FROM Account';
    if (!accountsWithOrders.isEmpty()) {
        query += ' WHERE Id NOT IN :accountsWithOrders';
    }

    return Database.getQueryLocator(query);
}


    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Task> tasksToInsert = new List<Task>();
        Date dueDate = Date.today().addDays(5);

        for (Account acc : (List<Account>)scope) {
            tasksToInsert.add(new Task(
                WhatId = acc.Id,
                OwnerId = acc.OwnerId,
                Subject = 'Call',
                Status = 'Nouvelle',
                Priority = 'Normale',
                ActivityDate = dueDate
            ));
        }

        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
global void finish(Database.BatchableContext bc) {
        
    }
    
}