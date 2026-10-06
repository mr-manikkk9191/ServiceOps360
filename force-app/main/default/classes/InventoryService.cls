public with sharing class InventoryService {

    /** BEFORE INSERT: default the price from the part and block over-consumption. */
    public static void validateAndPrice(List<Part_Usage__c> usages) {
        Map<Id, Decimal> requested = totalByPart(usages);
        Map<Id, Part__c> parts = new Map<Id, Part__c>(PartSelector.byIds(requested.keySet()));
        for (Part_Usage__c u : usages) {
            Part__c p = parts.get(u.Part__c);
            if (p == null) {
                continue;
            }
            if (u.Unit_Price__c == null) {
                u.Unit_Price__c = p.Unit_Cost__c;
            }
            Decimal stock = p.Current_Stock__c == null ? 0 : p.Current_Stock__c;
            if (requested.get(p.Id) > stock) {
                u.addError('Insufficient stock for ' + p.Name + '. Available: ' + stock + ', requested: ' + requested.get(p.Id));
            }
        }
    }

    /** AFTER INSERT: decrement stock (rows locked) and raise one purchase request if at/below reorder level. */
    public static void consume(List<Part_Usage__c> usages) {
        Map<Id, Decimal> used = totalByPart(usages);
        List<Part__c> parts = PartSelector.byIdsForUpdate(used.keySet());
        Set<Id> lowStock = new Set<Id>();
        for (Part__c p : parts) {
            Decimal stock = (p.Current_Stock__c == null ? 0 : p.Current_Stock__c) - used.get(p.Id);
            if (stock < 0) {
                throw new ServiceOpsException('Stock for ' + p.Name + ' would go negative.');
            }
            p.Current_Stock__c = stock;
            if (p.Reorder_Level__c != null && stock <= p.Reorder_Level__c) {
                lowStock.add(p.Id);
            }
        }
        update parts;
        createPurchaseRequests(parts, lowStock);
    }

    private static void createPurchaseRequests(List<Part__c> parts, Set<Id> lowStock) {
        if (lowStock.isEmpty()) {
            return;
        }
        Set<Id> alreadyRequested = PartSelector.partIdsWithOpenRequest(lowStock);
        List<Purchase_Request__c> requests = new List<Purchase_Request__c>();
        for (Part__c p : parts) {
            if (lowStock.contains(p.Id) && !alreadyRequested.contains(p.Id)) {
                Decimal qty = p.Reorder_Level__c * 2 - p.Current_Stock__c;
                requests.add(new Purchase_Request__c(Part__c = p.Id, Quantity__c = qty > 0 ? qty : 1, Status__c = 'OPEN'));
            }
        }
        insert requests;
    }

    private static Map<Id, Decimal> totalByPart(List<Part_Usage__c> usages) {
        Map<Id, Decimal> totals = new Map<Id, Decimal>();
        for (Part_Usage__c u : usages) {
            if (u.Part__c == null || u.Quantity__c == null) {
                continue;
            }
            Decimal current = totals.containsKey(u.Part__c) ? totals.get(u.Part__c) : 0;
            totals.put(u.Part__c, current + u.Quantity__c);
        }
        return totals;
    }
}
