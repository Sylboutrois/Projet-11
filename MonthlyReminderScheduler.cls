global class MonthlyReminderScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        Date today = Date.today();

        // Si ce n’est pas le premier lundi, on ne lance pas
        if (today.toStartOfMonth().addDays(0).toStartOfWeek() == today.toStartOfMonth() && today.day() <= 7) {
            Database.executeBatch(new BatchReminderForAccountsWithoutOrders(), 200);
        }
    }

    // Utilise cette méthode une seule fois pour planifier le batch
    public static void scheduleMonthly() {
        String cron = '0 0 8 1 * ?'; // Chaque 1er du mois à 8h00
        System.schedule('Monthly Account Reminder', cron, new MonthlyReminderScheduler());
    }
}