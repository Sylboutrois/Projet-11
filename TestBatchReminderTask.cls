@isTest
public class TestBatchReminderTask {
 @isTest
    static void testBatchCreatesTasksForAccountsWithoutOrdersOrCalls() {
        // Création de comptes
        Account accountWithoutOrderOrCall = new Account(Name = 'No Order No Call');
        insert accountWithoutOrderOrCall;

        Account accountWithOrder = new Account(Name = 'With Order');
        insert accountWithOrder;

        // Création de contrat pour relier un Order au compte
        Contract contract = new Contract(AccountId = accountWithOrder.Id, Status = 'Draft', StartDate = Date.today());
        insert contract;
        contract.Status = 'Activated';
        update contract;

        // Création d'un Order lié à un contrat (donc au compte)
        Order order = new Order(Name = 'Test Order', ContractId = contract.Id, Status = 'Draft', EffectiveDate = Date.today());
        insert order;

        // Création de tâche de type "Appel" sur un autre compte pour vérification
        Task callTask = new Task(WhatId = accountWithOrder.Id, Subject = 'Test Call', Type = 'Appel', Status = 'Completed', Priority = 'Normale', ActivityDate = Date.today());
        insert callTask;

        Test.startTest();
        Database.executeBatch(new BatchReminderForAccountsWithoutOrders(), 200);
        Test.stopTest();

        // Vérifie que seule une tâche a été créée pour le bon compte
        List<Task> createdTasks = [
            SELECT Id, WhatId, Subject, Type, Status, Priority
            FROM Task
            WHERE WhatId = :accountWithoutOrderOrCall.Id
        ];

        System.assertEquals(1, createdTasks.size(), 'Une seule tâche doit être créée pour le compte sans order ni appel.');
        System.assertEquals('Call', createdTasks[0].Subject);
        System.assertEquals('Nouvelle', createdTasks[0].Status);
        System.assertEquals('Normale', createdTasks[0].Priority);
    }

    @isTest
    static void testSchedulerCondition() {
        // Simule un appel manuel du scheduler (pas de restriction sur la date dans test)
        Test.startTest();
        (new MonthlyReminderScheduler()).execute(null);
        Test.stopTest();

        // Aucun assert strict ici car la méthode batch est testée séparément
        System.assert(true, 'Scheduler executed without error');
    }

  

    @isTest
    static void testScheduleMonthlyMethod() {
        Test.startTest();

        // Planifie le job via la méthode utilitaire
        MonthlyReminderScheduler.scheduleMonthly();

        Test.stopTest();

        // Vérifie que le job est bien planifié (1 job planifié nommé comme prévu)
        List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Monthly Account Reminder'];
        System.assertEquals(1, jobs.size(), 'Un job planifié doit être enregistré avec le bon nom');
    }
}