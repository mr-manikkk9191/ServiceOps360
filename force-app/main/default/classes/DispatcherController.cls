public with sharing class DispatcherController {
    @AuraEnabled
    public static List<TechnicianAssignmentService.Recommendation> getRecommendations(Id caseId) {
        try {
            return TechnicianAssignmentService.recommend(caseId);
        } catch (Exception e) {
            throw toAura(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id assignTechnician(Id caseId, Id technicianId) {
        try {
            return TechnicianAssignmentService.assign(caseId, technicianId).Id;
        } catch (DmlException e) {
            throw toAura(e.getDmlMessage(0));
        } catch (Exception e) {
            throw toAura(e.getMessage());
        }
    }

    private static AuraHandledException toAura(String message) {
        AuraHandledException ex = new AuraHandledException(message);
        ex.setMessage(message);
        return ex;
    }
}
