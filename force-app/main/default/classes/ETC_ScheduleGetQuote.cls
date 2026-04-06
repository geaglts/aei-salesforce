public with sharing class ETC_ScheduleGetQuote implements Schedulable {
     public void execute(SchedulableContext sc) {
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE isStandard = TRUE];
		ETC_QueueGetQuotes.queue(1, false, Test.isRunningTest() ? Test.getStandardPricebookId() : standardPricebook.Id, null, null);
		Id jobId = sc.getTriggerId();
		System.abortJob(jobId);
		// ejecuta el nuevo proceso en el tiempo especificado
		if (!Test.isRunningTest()) {
			System.schedule(ETC_ScheduleGetQuote.class.getName(), ETC_Utility.getCRONString(ETC_GetQuoteWs.ENDPOINT_NAME), new ETC_ScheduleGetQuote());
		}
	}

	// ETC_ScheduleGetQuote.start('2026-04-06 6:00am');
	public static void start(String dateToStart) {
		if (!Test.isRunningTest()) {
			System.schedule(ETC_ScheduleGetQuote.class.getName(), ETC_Utility.getSpecificTimeCron(dateToStart), new ETC_ScheduleGetQuote());
		}
	}
}