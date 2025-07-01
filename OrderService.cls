public class OrderService {
 //Methode 01 pour bloquer le passage de Draft a Activated si pas de produits
    public static void validateOrderStatusChange(List<Order> newOrders, Map<Id, Order> oldOrderMap) {
        Set<Id> orderIdsToCheck = new Set<Id>();

        for (Order ord : newOrders) {
            Order oldOrd = oldOrderMap.get(ord.Id);

            // Vérifie si le statut passe de 'Draft' à 'Activated'
            if (oldOrd.Status == 'Draft' && ord.Status == 'Activated') {
                orderIdsToCheck.add(ord.Id);
            }
        }

        if (!orderIdsToCheck.isEmpty()) {
            // Récupère les OrderItems (Order Products) liés aux Orders concernés
            Map<Id, Integer> orderItemCounts = new Map<Id, Integer>();
            for (AggregateResult ar : [
                SELECT OrderId, COUNT(Id) OrderCount
                FROM OrderItem
                WHERE OrderId IN :orderIdsToCheck
                GROUP BY OrderId
            ]) {
                orderItemCounts.put((Id)ar.get('OrderId'), (Integer)ar.get('OrderCount'));
            }

            // Valide qu'il y a bien au moins un OrderItem pour chaque Order
            for (Order ord : newOrders) {
                if (orderIdsToCheck.contains(ord.Id) && !orderItemCounts.containsKey(ord.Id)) {
                    ord.addError('Impossible de passer l\'Order en statut "Activated" sans avoir au moins un produit associé.');
                }
            }
        }
    }// Méthode 02 : pour décocher Active__c sur Account si tous les Orders sont supprimés
    public static void updateAccountActiveFlag(
        Map<Id, Order> newMap,
        Map<Id, Order> oldMap,
        Boolean isInsert,
        Boolean isUpdate,
        Boolean isDelete
    ) {
        Set<Id> contractIds = new Set<Id>();

        // Collecter les ContractId depuis newMap (insert/update)
        if (isInsert || isUpdate) {
            for (Order ord : newMap.values()) {
                if (ord.ContractId != null) {
                    contractIds.add(ord.ContractId);
                }
            }
        }

        // Collecter les ContractId depuis oldMap (delete)
        if (isDelete) {
            for (Order ord : oldMap.values()) {
                if (ord.ContractId != null) {
                    contractIds.add(ord.ContractId);
                }
            }
        }

        if (contractIds.isEmpty()) {
            return;
        }

        // Récupérer les contrats avec leurs comptes
        Map<Id, Contract> contractMap = new Map<Id, Contract>(
            [SELECT Id, AccountId FROM Contract WHERE Id IN :contractIds]
        );

        Set<Id> accountIds = new Set<Id>();
        for (Contract c : contractMap.values()) {
            if (c.AccountId != null) {
                accountIds.add(c.AccountId);
            }
        }

        if (accountIds.isEmpty()) {
            return;
        }

        // Identifier les comptes avec au moins une Order
        Set<Id> activeAccountIds = new Set<Id>();
        for (AggregateResult ar : [
            SELECT Contract.AccountId accId
            FROM Order
            WHERE Contract.AccountId IN :accountIds
            GROUP BY Contract.AccountId
        ]) {
            activeAccountIds.add((Id) ar.get('accId'));
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (Id accId : accountIds) {
            Account acc = new Account(Id = accId);
            acc.Active__c = activeAccountIds.contains(accId);
            accountsToUpdate.add(acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}