@IsTest
public class TestDataFactory {
    public static Skill__c skill(String name) {
        Skill__c s = new Skill__c(Name = name);
        insert s;
        return s;
    }
    public static Technician__c technician(String name, Decimal lat, Decimal lon, String status, Decimal workload) {
        Technician__c t = new Technician__c(Name = name, Latitude__c = lat, Longitude__c = lon, Status__c = status, Current_Workload__c = workload);
        insert t;
        return t;
    }
    public static void link(Technician__c t, Skill__c s) {
        insert new Technician_Skill__c(Technician__c = t.Id, Skill__c = s.Id);
    }
    public static Case serviceCase(String subject, String category, String priority, Decimal lat, Decimal lon) {
        Case c = new Case(Subject = subject, Service_Category__c = category, Priority = priority, Origin = 'Phone', Location_Latitude__c = lat, Location_Longitude__c = lon);
        insert c;
        return c;
    }
    public static Part__c part(String name, String sku, Decimal cost, Decimal stock, Decimal reorder) {
        Part__c p = new Part__c(Name = name, SKU__c = sku, Unit_Cost__c = cost, Current_Stock__c = stock, Reorder_Level__c = reorder);
        insert p;
        return p;
    }
    /** Case + available tech with matching skill + assigned work order. */
    public static Work_Order__c assignedWorkOrder() {
        Skill__c s = skill('AC Repair');
        Technician__c t = technician('Tech One', 30.74, 76.79, 'AVAILABLE', 0);
        link(t, s);
        Case c = serviceCase('AC not cooling', 'AC Repair', 'High', 30.74, 76.79);
        return TechnicianAssignmentService.assign(c.Id, t.Id);
    }
    public static void advance(Work_Order__c wo, List<String> statuses) {
        for (String s : statuses) {
            wo.Status__c = s;
            update wo;
        }
    }
}
