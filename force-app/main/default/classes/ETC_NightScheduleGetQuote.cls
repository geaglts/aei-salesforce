public with sharing class ETC_NightScheduleGetQuote implements Schedulable {

    public void execute(SchedulableContext sc) {
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE isStandard = TRUE];
		ETC_QueueGetQuotes.queue(1, false, Test.isRunningTest() ? Test.getStandardPricebookId() : standardPricebook.Id, null, null);
		Id jobId = sc.getTriggerId();
        System.abortJob(jobId);
        // Executes the new process at specified time
        if (!Test.isRunningTest()) {
            System.schedule(ETC_NightScheduleGetQuote.class.getName(), ETC_Utility.getCRONString(ETC_GetQuoteWs.ENDPOINT_NAME), new ETC_NightScheduleGetQuote());
        }
    }

    // Execute manually with: ETC_NightScheduleGetQuote.start('2026-04-06 10:00am');
    public static void start(String dateToStart) {
        if (!Test.isRunningTest()) {
            System.schedule(ETC_NightScheduleGetQuote.class.getName(), ETC_Utility.getSpecificTimeCron(dateToStart), new ETC_NightScheduleGetQuote());
        }
    }
}