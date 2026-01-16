import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getQuote from "@salesforce/apex/ETC_GetQuoteWs.getQuote";
import findQuoteByExternalId from "@salesforce/apex/ETC_SyncQuoteController.findQuoteByExternalId";
import getAccount from "@salesforce/apex/ETC_SyncQuoteController.getAccount";
import getOpportunity from "@salesforce/apex/ETC_SyncQuoteController.getOpportunity";
import generateRecordLink from "@salesforce/apex/ETC_SyncQuoteController.generateRecordLink";
import saveQuoteRecord from "@salesforce/apex/ETC_SyncQuoteController.saveQuoteRecord";

function logob(content) {
  console.log(
    "==========================+++++++++++++++=========================="
  );
  console.log("LOG:", JSON.stringify(content, null, 4));
  console.log(
    "==========================+++++++++++++++=========================="
  );
}

export default class EtcGetQuote extends LightningElement {
  @api recordId;
  @api objectApiName;
  @track quoteData = {};
  @track opportunityUrl = null;
  @track quoteUrl = null;
  @track createdOrders = [];

  loading = false;
  isUpdate = false;

  clearView() {
    this.quoteData = {};
    this.formRef = this.template.querySelector(".searchForm");
    this.formRef.reset();
    this.opportunityUrl = null;
    this.quoteUrl = null;
    this.loading = false;
    this.isUpdate = false;
    this.createdOrders = [];
  }

  async searchQuote(evt) {
    evt.preventDefault();
    this.loading = true;
    try {
      const data = Object.fromEntries(new FormData(evt.currentTarget));
      if (!data.quoteId) {
        this.showToast({
          message: "Por favor ingrese el código de la cotización",
          title: "Datos incompletos",
          variant: "warning",
        });
        return;
      }
      const serviceQuoteData = await getQuote({ quoteId: data.quoteId });
      const sfQuote = await findQuoteByExternalId({ externalId: data.quoteId });
      this.quoteUrl = await generateRecordLink({ recordId: sfQuote?.Id });
      serviceQuoteData.data._sfAccount = await getAccount({
        externalId: serviceQuoteData.data.Cliente,
      });
      serviceQuoteData.data._sfOpp = await getOpportunity({
        identificationCode:
          sfQuote?.OpportunityId || serviceQuoteData.data.MovID,
      });
      this.opportunityUrl = await generateRecordLink({
        recordId: serviceQuoteData.data._sfOpp?.Id,
      });
      serviceQuoteData.data.sfOppId = serviceQuoteData.data._sfOpp?.Id;
      serviceQuoteData.data.sfAccountId = serviceQuoteData.data._sfAccount?.Id;
      this.quoteData = JSON.parse(JSON.stringify(serviceQuoteData));
      /**
       * Si la cotizacion existe, entonces hace el upsert directamente
       * en caso de que no existe se espera a que el usuario confirme
       * y guarde la cotizacion con toda la logica que va detras
       */
      if (sfQuote) {
        console.log("Guarda la cotización...");
        this.isUpdate = true;
        await this.saveQuote(true);
      }
    } catch (error) {
      console.log(error.message);
    } finally {
      this.loading = false;
    }
  }

  async saveQuote(isUpdate) {
    this.loading = true;
    try {
      const result = await saveQuoteRecord({
        rawNewQuoteData: JSON.stringify(this.quoteData),
      });
      // logob(result);
      if (result.error) {
        this.showToast({
          message: result.error,
          title: "A ocurrido un error",
          variant: "error",
        });
      } else if (isUpdate) {
        this.showToast({
          message:
            "La cotización fue actualizada correctamente, debajo del buscador podrás visualizar los enlaces a los registros creados.",
          title: "Actualización exitosa",
          variant: "success",
        });
      } else if (result.quoteUrl) {
        this.showToast({
          message:
            "La cotización fue creada correctamente, debajo del buscador podrás visualizar los enlaces a los registros creados.",
          title: "Operación exitosa",
          variant: "success",
        });
      }
      for await (let createdOrder of JSON.parse(result.createdOrders)) {
        this.createdOrders.push({
          link: await generateRecordLink({ recordId: createdOrder.Id }),
          ...createdOrder,
        });
      }
      this.opportunityUrl = result.opportunityUrl;
      this.quoteUrl = result.quoteUrl;
      this.quoteData.data._sfOpp = await getOpportunity({
        identificationCode: result.opportunityCreatedId,
      });
    } catch (error) {
      // Handle error
      console.log(error.message);
    } finally {
      this.loading = false;
    }
  }

  async onChangeOpportunity(evt) {
    this.quoteData.data._sfOpp = { Id: evt.detail.recordId };
    this.quoteData.data.sfOppId = evt.detail.recordId;
  }

  showToast({ title = "Name", message = "Description", variant = "success" }) {
    const event = new ShowToastEvent({
      title,
      message,
      variant,
    });
    this.dispatchEvent(event);
  }
}
