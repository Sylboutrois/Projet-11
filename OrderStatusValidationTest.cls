@isTest
public class OrderStatusValidationTest {

    @isTest
    static void testOrderCannotBeActivatedWithoutOrderItems() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contract con = new Contract(
            AccountId = acc.Id,
            StartDate = Date.today(),
            Status = 'Draft'
        );
        insert con;

        Order ord = new Order(
            AccountId = acc.Id,
            ContractId = con.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
        );
        insert ord;

        ord.Status = 'Activated';

        Test.startTest();
        try {
            update ord;
            System.assert(false, 'Une exception aurait dû être levée');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Impossible de passer l\'Order en statut "Activated"'));
        }
        Test.stopTest();
    }

    @isTest
static void testOrderCanBeActivatedWithOrderItems() {
    // Crée un compte
    Account acc = new Account(Name = 'Test Account');
    insert acc;

    // Crée un contrat actif lié au compte
    Contract con = new Contract(
        AccountId = acc.Id,
        StartDate = Date.today(),
        Status = 'Draft'
    );
    insert con;
    con.Status = 'Activated';
	Update con;
   

    // Crée un produit actif
    Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
    insert prod;

    // Crée une PricebookEntry pour ce produit
    PricebookEntry pbe = new PricebookEntry(
        Pricebook2Id = '01sgK000001HQIUQA4',
        Product2Id = prod.Id,
        UnitPrice = 100,
        IsActive = true
    );
    insert pbe;

    // Crée un Order en statut Draft, lié au compte, contrat et à la Pricebook
    Order ord = new Order(
        AccountId = acc.Id,
        ContractId = con.Id,
        Pricebook2Id = '01sgK000001HQIUQA4',
        EffectiveDate = Date.today(),
        Status = 'Draft'
    );
    insert ord;

    // Crée un OrderItem lié à l'Order
    OrderItem oi = new OrderItem(
        OrderId = ord.Id,
        Quantity = 1,
        UnitPrice = 100,
        PricebookEntryId = pbe.Id
    );
    insert oi;

    // Recharge l'Order pour changer le statut
    ord = [SELECT Id, Status FROM Order WHERE Id = :ord.Id];
    ord.Status = 'Activated';

    Test.startTest();
    update ord;
    Test.stopTest();

    // Vérifie que le statut a bien été mis à jour
    Order updatedOrder = [SELECT Status FROM Order WHERE Id = :ord.Id];
    System.assertEquals('Activated', updatedOrder.Status);
}

}