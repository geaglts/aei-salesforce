public class ETC_AeiQuoteModel {
    @AuraEnabled
    public Data data;

    public class Data {
        @AuraEnabled
        public Integer ID; // 993
        @AuraEnabled
        public Integer Sucursal; // 2
        @AuraEnabled
        public String Cliente; // "94"
        @AuraEnabled
        public String Mov; // "Cotizacion"
        @AuraEnabled
        public String MovID; // "CAR13"
        @AuraEnabled
        public String FechaEmision; // "2022-05-03T00:00:00.000Z"
        @AuraEnabled
        public String FechaOriginal;
        @AuraEnabled
        public String Concepto; // "Compra"
        @AuraEnabled
        public String Referencia; // "4000026518"
        @AuraEnabled
        public String Observaciones;
        @AuraEnabled
        public String Almacen; // "01CARMEN"
        @AuraEnabled
        public String Moneda; // "Pesos"
        @AuraEnabled
        public Integer TipoCambio; // 1
        @AuraEnabled
        public String Agente; // "HRODRIGUEZ"
        @AuraEnabled
        public String Usuario; // "MGUIZAR"
        @AuraEnabled
        public String Estatus; // "CONCLUIDO"
        @AuraEnabled
        public String FormaEnvio; // "Flete Terrestre"
        @AuraEnabled
        public String Condicion; // "60Dias"
        @AuraEnabled
        public String ListaPreciosEsp; // "C.Gral Carmen MXN"
        @AuraEnabled
        public String ZonaImpuesto; // "IVA 16"
        @AuraEnabled
        public String sfOppId;
        @AuraEnabled
        public String sfAccountId;
        @AuraEnabled
        public List<SucursalCta> SucursalCta;
        @AuraEnabled
        public List<ClienteCta> ClienteCta;
        @AuraEnabled
        public List<DestinoCta> DestinoCta;
        @AuraEnabled
        public List<VentaDCta> VentaDCta;
    }

    public class SucursalCta {
        @AuraEnabled
        public Integer Sucursal; // 2
        @AuraEnabled
        public String Nombre; // "CARMEN"
        @AuraEnabled
        public String Prefijo; // "CAR  "
        @AuraEnabled
        public String Direccion; // "Calle 20-A entre 47 y 49"
        @AuraEnabled
        public String DireccionNumero; // "14"
        @AuraEnabled
        public String Delegacion; // "Carmen"
        @AuraEnabled
        public String Colonia; // "Pallas"
        @AuraEnabled
        public String Poblacion; // "Ciudad del Carmen"
        @AuraEnabled
        public String Estado; // "Campeche"
        @AuraEnabled
        public String CodigoPostal; // "24140"
        @AuraEnabled
        public String RFC; // "AEI861027P26"
    }

    public class ClienteCta {
        @AuraEnabled
        public String Nombre; // "CONSTRUCTORA SUBACUATICA DIAVAZ"
        @AuraEnabled
        public String Direccion; // "AV REVOLUCION PISO 3 DESPACHO B-2"
        @AuraEnabled
        public String DireccionNumero; // "468"
        @AuraEnabled
        public String Delegacion; // "Benito Juárez"
        @AuraEnabled
        public String Colonia; // "San Pedro de los Pinos"
        @AuraEnabled
        public String Poblacion; // "Ciudad de México"
        @AuraEnabled
        public String Estado; // "Ciudad de México"
        @AuraEnabled
        public String CodigoPostal; // "03800"
        @AuraEnabled
        public String RFC; // "CSD840531F39"
        @AuraEnabled
        public String eMail1; // "facturacion_electronica@diavaz.com"
    }

    public class DestinoCta {
        @AuraEnabled
        public Integer ID; // 995
        @AuraEnabled
        public String Mov; // "Pedido"
        @AuraEnabled
        public String MovID; // "CAR92"
        @AuraEnabled
        public List<DestinoCta> DestPedidoCte;
        @AuraEnabled
        public String FechaEmision; // "2022-05-03T00:00:00"
        @AuraEnabled
        public String Origen; // "Cotizacion"
        @AuraEnabled
        public String OrigenID; // "CAR13"
        @AuraEnabled
        public String Agente; // "HRODRIGUEZ"
        @AuraEnabled
        public String Estatus; // "CONCLUIDO"
        @AuraEnabled
        public String Moneda; // "Pesos"
        @AuraEnabled
        public Integer TipoCambio; // 1
        @AuraEnabled
        public List<DetalleDtoCta> DetalleDtoCta;
        @AuraEnabled
        public List<DetalleDtoCta> DestDetPedidoCte;
    }

    public class DetalleDtoCta {
        @AuraEnabled
        public String Aplica; // "Cotizacion"
        @AuraEnabled
        public String AplicaID; // "CAR13"
        @AuraEnabled
        public Integer AplicaRenglon; // 2048
        @AuraEnabled
        public String Articulo; // "EL-AEC0-0041"
        @AuraEnabled
        public String ClaveFabricante; // "UR-3X12-AR"
        @AuraEnabled
        public String Unidad; // "ML"
        @AuraEnabled
        public Integer Cantidad; // 600
        @AuraEnabled
        public Double Precio; // 43.59
        @AuraEnabled
        public Integer Impuesto1; // 16
        @AuraEnabled
        public Double Costo; // 34.6255
        @AuraEnabled
        public String ContUso2; // "10"
        @AuraEnabled
        public Double Importe; // 26154
    }

    public class VentaDCta {
        @AuraEnabled
        public Integer Renglon; // 2048
        @AuraEnabled
        public String RenglonTipo; // "L"
        @AuraEnabled
        public String Articulo; // "EL-AEC0-0041"
        @AuraEnabled
        public String Unidad; // "ML"
        @AuraEnabled
        public String ThoCodigoFabricante; // "UR-3X12-AR"
        @AuraEnabled
        public Integer Cantidad; // 600
        @AuraEnabled
        public Double Precio; // 43.59
        @AuraEnabled
        public Integer Impuesto1; // 16
        @AuraEnabled
        public Double Costo; // 34.6255
        @AuraEnabled
        public String ContUso; // "03"
        @AuraEnabled
        public String ContUso2; // "10"
        @AuraEnabled
        public String FechaRequerida; // "2022-05-03T00:00:00"
        @AuraEnabled
        public Boolean ThoDescAmpliada; // true
    }

    public static ETC_AeiQuoteModel parse(String jsonString) {
        return (ETC_AeiQuoteModel) JSON.deserialize(jsonString, ETC_AeiQuoteModel.class);
    }
}