public with sharing class ETC_AeiQuoteDataModel {
    @AuraEnabled
    public Integer ID; // 224745
    @AuraEnabled
    public Integer Sucursal; // 0
    @AuraEnabled
    public String Cliente; // "289"
    @AuraEnabled
    public String Mov; // "Cotizacion"
    @AuraEnabled
    public String MovID; // "MID34400"
    @AuraEnabled
    public String FechaEmision; // "2025-11-21T00:00:00.000Z"
    @AuraEnabled
    public String FechaOriginal;
    @AuraEnabled
    public String Concepto; // "Concurso"
    @AuraEnabled
    public String Referencia;
    @AuraEnabled
    public String Observaciones;
    @AuraEnabled
    public String Almacen; // "001MERIDA"
    @AuraEnabled
    public String Moneda; // "Pesos"
    @AuraEnabled
    public Integer TipoCambio; // 1
    @AuraEnabled
    public String Agente; // "JPAREJA"
    @AuraEnabled
    public String Usuario; // "JYAM"
    @AuraEnabled
    public String Estatus; // "CONCLUIDO"
    @AuraEnabled
    public String FormaEnvio; // "Flete Terrestre"
    @AuraEnabled
    public String Condicion; // "30Dias"
    @AuraEnabled
    public String ListaPreciosEsp; // "V.Gral Mid/Cun MXN"
    @AuraEnabled
    public String ZonaImpuesto; // "IVA 0 a 16"
    @AuraEnabled
    public List<SucursalCta> SucursalCta;
    @AuraEnabled
    public List<ClienteCta> ClienteCta;
    @AuraEnabled
    public List<DestinoCta> DestinoCta;
    @AuraEnabled
    public List<VentaDCta> VentaDCta;
    @AuraEnabled
    public String sfAccountId;
    @AuraEnabled
    public String sfOppId;

    public class SucursalCta {
        @AuraEnabled
        public Integer Sucursal; // 0
        @AuraEnabled
        public String Nombre; // "MERIDA"
        @AuraEnabled
        public String Prefijo; // "MID  "
        @AuraEnabled
        public String Direccion; // "Calle 60 Diagonal por 59"
        @AuraEnabled
        public String DireccionNumero; // "483A"
        @AuraEnabled
        public String Delegacion; // "Mérida"
        @AuraEnabled
        public String Colonia; // "Ejido de Chuburna"
        @AuraEnabled
        public String Estado; // "Yucatán"
        @AuraEnabled
        public String CodigoPostal; // "97300"
        @AuraEnabled
        public String RFC; // "AEI861027P26"
    }

    public class ClienteCta {
        @AuraEnabled
        public String Nombre; // "EDIFICTUN"
        @AuraEnabled
        public String Direccion; // "CALLE 60"
        @AuraEnabled
        public String DireccionNumero; // "485"
        @AuraEnabled
        public String EntreCalles; // "N/A Y 60 DIAGONAL"
        @AuraEnabled
        public String Delegacion; // "Mérida"
        @AuraEnabled
        public String Colonia; // "Parque Industrial Yucatán"
        @AuraEnabled
        public String Estado; // "Yucatán"
        @AuraEnabled
        public String CodigoPostal; // "97302"
        @AuraEnabled
        public String RFC; // "EDI140303I97"
        @AuraEnabled
        public String eMail1; // ""
    }

    public class DestinoCta {
        @AuraEnabled
        public Integer ID; // 224749
        @AuraEnabled
        public String Mov; // "Pedido"
        @AuraEnabled
        public String MovID; // "MID14803"
        @AuraEnabled
        public String FechaEmision; // "2025-11-21T00:00:00"
        @AuraEnabled
        public String Origen; // "Cotizacion"
        @AuraEnabled
        public String OrigenID; // "MID34400"
        @AuraEnabled
        public String Agente; // "JPAREJA"
        @AuraEnabled
        public String Estatus; // "CONCLUIDO"
        @AuraEnabled
        public String Moneda; // "Pesos"
        @AuraEnabled
        public Integer TipoCambio; // 1
        @AuraEnabled
        public List<DetalleDtoCta> DetalleDtoCta;
    }

    public class DetalleDtoCta {
        @AuraEnabled
        public String Aplica; // "Cotizacion"
        @AuraEnabled
        public String AplicaID; // "MID34400"
        @AuraEnabled
        public Integer AplicaRenglon; // 2048
        @AuraEnabled
        public String Articulo; // "EL-SOP0-0030"
        @AuraEnabled
        public String ClaveFabricante; // "UÑA-34"
        @AuraEnabled
        public String DescArt; // "TEST DE DESCRIPCION"
        @AuraEnabled
        public String Unidad; // "PZ"
        @AuraEnabled
        public Integer Cantidad; // 5
        @AuraEnabled
        public Double Precio; // 1.1937
        @AuraEnabled
        public Integer DescuentoImporte; // 0
        @AuraEnabled
        public Integer Impuesto1; // 16
        @AuraEnabled
        public Double Costo; // 0.9586
        @AuraEnabled
        public String ContUso2; // "10"
        @AuraEnabled
        public Double Importe; // 5.97
    }

    public class VentaDCta {
        @AuraEnabled
        public Integer Renglon; // 2048
        @AuraEnabled
        public String RenglonTipo; // "N"
        @AuraEnabled
        public String Articulo; // "EL-SOP0-0030"
        @AuraEnabled
        public String DescArt; // "TEST DE DESCRIPCION"
        @AuraEnabled
        public String Unidad; // "PZ"
        @AuraEnabled
        public String ThoCodigoFabricante; // "UÑA-34"
        @AuraEnabled
        public Integer Cantidad; // 10
        @AuraEnabled
        public Double Precio; // 1.1937
        @AuraEnabled
        public Integer DescuentoImporte; // 0
        @AuraEnabled
        public Integer Impuesto1; // 16
        @AuraEnabled
        public Double Costo; // 0.9586
        @AuraEnabled
        public String ContUso2; // "10"
        @AuraEnabled
        public String FechaRequerida; // "2025-11-21T00:00:00"
        @AuraEnabled
        public Boolean ThoDescAmpliada; // true
    }
}