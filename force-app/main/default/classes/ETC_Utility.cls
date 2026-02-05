public with sharing class ETC_Utility {
	public static endpoint__mdt getEndpoint(String name) {
		return [
			SELECT method__c, endpoint__c, raw_response__c, env__c, timer__c
			FROM endpoint__mdt
			WHERE DeveloperName = :name
			LIMIT 1
		];
	}
    
	public static environment__mdt getEnv(String name) {
		return [
			SELECT host__c, username__c, password__c, token__c
			FROM environment__mdt
			WHERE DeveloperName = :name
			LIMIT 1
		];
	}

	public static List<Integer> showQueueResult(Database.UpsertResult[] upsertResult, String objectName, Integer page, Boolean sendEmail) {
		List<Integer> counter = new List<Integer>();
		Integer successCount = 0;
		Integer errorCount = 0;

		String body = '';
		body += '\n' + objectName;
		body += '\n' + page;
		for (Database.UpsertResult sr : upsertResult) {
			if (sr.isSuccess()) {
				successCount++;
			} else {
				System.debug('// ERROR - RECORD: ' + objectName);
				System.debug(sr);
				body += '\n// ERROR - RECORD\n';
				body += sr.getId();
				errorCount++;
				for (Database.Error err : sr.getErrors()) {
					System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());
					body += '\nerror has occurred.' + err.getStatusCode() + ': ' + err.getMessage();
					System.debug('fields that affected this error: ' + err.getFields());
					body += '\nfields that affected this error: ' + err.getFields();
				}
			}
		}

		counter.add(successCount);
		counter.add(errorCount);

        if (sendEmail) {
            if (errorCount > 0) {
                Messaging.reserveSingleEmailCapacity(2);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new List<String>{ 'miguel.angel@etcloudmx.com' };
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('miguel.angel@etcloudmx.com');
                mail.setSenderDisplayName('Salesforce Support');
                mail.setSubject('Queue Errors');
                mail.setPlainTextBody(body);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
            }
        }

		return counter;
	}

	public static String getCRONString(String metadataName) {
		DateTime nextRunTime;
		if (metadataName != '') {
			endpoint__mdt mdt = ETC_Utility.getEndpoint(metadataName);
			nextRunTime = DateTime.now().addMinutes(Integer.valueOf(mdt.timer__c));
		} else {
			nextRunTime = DateTime.now().addMinutes(1);
		}
		String cronString =
			'' +
			nextRunTime.second() +
			' ' +
			nextRunTime.minute() +
			' ' +
			nextRunTime.hour() +
			' ' +
			nextRunTime.day() +
			' ' +
			nextRunTime.month() +
			' ? ' +
			nextRunTime.year();
		return cronString;
	}

    public static void updateEnvironmentMetadata(String metadataName, String fieldApiName, String newValue) {
		/**
		 * Consulta el registro que queremos modificar
		 * en este caso el nombre del metadato especifico
		 */
		List<environment__mdt> registros = [
			SELECT DeveloperName, MasterLabel
			FROM environment__mdt
			WHERE DeveloperName = :metadataName
		];

		/**
		 * Si el registro no existe entonces nos regresa un error
		 * indicando que no fue encontrado
		 */
		if (registros.isEmpty()) {
			throw new IllegalArgumentException('No existe registro con DeveloperName ' + metadataName);
		}

		/**
		 * Se genera la instancia de Metadata que sera desplegada (actualizada)
		 * con base en los valores del nombre completo <metadata_api_name>.<record_metada_api_name>
		 * y el nombre del registro
		 */
		Metadata.CustomMetadata mmd = new Metadata.CustomMetadata();
		mmd.fullName = 'environment__mdt.' + metadataName;
		mmd.label = registros[0].MasterLabel;

		/**
		 * Al ya existir el registro solamente actualizamos lo que necesitamos
		 * ingresando el nombre del campo del metadato y el nuevo valor que tendra
		 * estos cambios los agregamos dentro de nuestro Metadata.CustomMetadata
		 * previamente creado
		 */
		Metadata.CustomMetadataValue cmdv = new Metadata.CustomMetadataValue();
		cmdv.field = fieldApiName;
		cmdv.value = newValue;
		mmd.values.add(cmdv);

		/**
		 * Por ultimo creamos la instancia de despliegue
		 * que es la que se encargara de actualizar la informacion
		 *
		 * Este proceso ocurre de forma asincrona por lo que tomara
		 * unos momentos en verse reflejado
		 */
		Metadata.DeployContainer container = new Metadata.DeployContainer();
		container.addMetadata(mmd);

		Id jobId = Test.isRunningTest() ? '001000000000001AAA' : Metadata.Operations.enqueueDeployment(container, null);
	}
}