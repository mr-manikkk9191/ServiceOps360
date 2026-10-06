trigger JobCompletedTrigger on Job_Completed__e(after insert) {
    CaseCompletionService.handle(Trigger.new);
}
