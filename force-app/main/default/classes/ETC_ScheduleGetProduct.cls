public with sharing class ETC_ScheduleGetProduct implements Schedulable {
     public void execute(SchedulableContext sc) {
		ETC_QueueGetProduct.queue(1, false);
		Id jobId = sc.getTriggerId();
		System.abortJob(jobId);
		// ejecuta el nuevo proceso en el tiempo especificado
		if (!Test.isRunningTest()) {
			System.schedule(ETC_ScheduleGetProduct.class.getName(), ETC_Utility.getCRONString(ETC_WsGetProducts.ENDPOINT_NAME), new ETC_ScheduleGetProduct());
		}
	}

	public static void start() {
		if (!Test.isRunningTest()) {
			System.schedule(ETC_ScheduleGetProduct.class.getName(), ETC_Utility.getCRONString(''), new ETC_ScheduleGetProduct());
		}
	}
}