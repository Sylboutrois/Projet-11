@isTest
public class OrderDeletionAccountUpdateTest {

    @isTest
    static void testAccountFlagDeactivatedWhenAllOrdersAreDeleted() {
        Account acc = new Account(Name = 'Client A', Active__c = true);
        insert acc;

        // Crée le contrat en mode Draft puis le passe en Activated
        Contract con = new Contract(AccountId = acc.Id, StartDate = Date.today(), Status = 'Draft');
        insert con;
        con.Status = 'Activated';
        update con;

        // Crée un produit actif
        Product2 prod = new Product2(Name = 'Produit A', IsActive = true);
        insert prod;

        // Utilise un Pricebook2Id fixe
        String pricebookId = '01sgK000001HQIUQA4';

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 10,
            IsActive = true
        );
        insert pbe;

        Order o1 = new Order(AccountId = acc.Id, ContractId = con.Id, Pricebook2Id = pricebookId, EffectiveDate = Date.today(), Status = 'Draft');
        Order o2 = new Order(AccountId = acc.Id, ContractId = con.Id, Pricebook2Id = pricebookId, EffectiveDate = Date.today(), Status = 'Draft');
        insert new List<Order>{ o1, o2 };

        Test.startTest();
        delete new List<Order>{ o1, o2 };
        Test.stopTest();

        Account updatedAcc = [SELECT Active__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(false, updatedAcc.Active__c, 'Active__c aurait dû être décoché');
    }

    @isTest
    static void testAccountFlagStaysActiveIfOrdersRemain() {
        Account acc = new Account(Name = 'Client B', Active__c = true);
        insert acc;

        Contract con = new Contract(AccountId = acc.Id, StartDate = Date.today(), Status = 'Draft');
        insert con;
        con.Status = 'Activated';
        update con;

        Product2 prod = new Product2(Name = 'Produit B', IsActive = true);
        insert prod;

        String pricebookId = '01sgK000001HQIUQA4';

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 10,
            IsActive = true
        );
        insert pbe;

        Order o1 = new Order(AccountId = acc.Id, ContractId = con.Id, Pricebook2Id = pricebookId, EffectiveDate = Date.today(), Status = 'Draft');
        Order o2 = new Order(AccountId = acc.Id, ContractId = con.Id, Pricebook2Id = pricebookId, EffectiveDate = Date.today(), Status = 'Draft');
        insert new List<Order>{ o1, o2 };

        Test.startTest();
        delete o1;
        Test.stopTest();

        Account updatedAcc = [SELECT Active__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(true, updatedAcc.Active__c, 'Active__c aurait dû rester coché');
    }
}