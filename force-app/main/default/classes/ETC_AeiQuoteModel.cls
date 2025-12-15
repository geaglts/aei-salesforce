public class ETC_AeiQuoteModel {
    public Data data;

    public class Data {
        public Integer ID; // 224745
        public Integer Sucursal; // 0
        public String Cliente; // "289"
        public String Mov; // "Cotizacion"
        public String MovID; // "MID34400"
        public String FechaEmision; // "2025-11-21T00:00:00.000Z"
        public String FechaOriginal;
        public String Concepto; // "Concurso"
        public String Referencia;
        public String Observaciones;
        public String Almacen; // "001MERIDA"
        public String Moneda; // "Pesos"
        public Integer TipoCambio; // 1
        public String Agente; // "JPAREJA"
        public String Usuario; // "JYAM"
        public String Estatus; // "CONCLUIDO"
        public String FormaEnvio; // "Flete Terrestre"
        public String Condicion; // "30Dias"
        public String ListaPreciosEsp; // "V.Gral Mid/Cun MXN"
        public String ZonaImpuesto; // "IVA 0 a 16"
        public List<SucursalCta> SucursalCta;
        public List<ClienteCta> ClienteCta;
        public List<VentaDCta> VentaDCta;
    }

    public class SucursalCta {
        public Integer Sucursal; // 0
        public String Nombre; // "MERIDA"
        public String Prefijo; // "MID  "
        public String Direccion; // "Calle 60 Diagonal por 59"
        public String DireccionNumero; // "483A"
        public String Delegacion; // "Mérida"
        public String Colonia; // "Ejido de Chuburna"
        public String Estado; // "Yucatán"
        public String CodigoPostal; // "97300"
        public String RFC; // "AEI861027P26"
    }

    public class ClienteCta {
        public String Nombre; // "EDIFICTUN"
        public String Direccion; // "CALLE 60"
        public String DireccionNumero; // "485"
        public String EntreCalles; // "N/A Y 60 DIAGONAL"
        public String Delegacion; // "Mérida"
        public String Colonia; // "Parque Industrial Yucatán"
        public String Estado; // "Yucatán"
        public String CodigoPostal; // "97302"
        public String RFC; // "EDI140303I97"
        public String eMail1; // ""
    }

    public class VentaDCta {
        public Integer Renglon; // 2048
        public String RenglonTipo; // "N"
        public String Articulo; // "EL-SOP0-0030"
        public String DescArt; // "TEST DE DESCRIPCION"
        public String Unidad; // "PZ"
        public String ThoCodigoFabricante; // "UÑA-34"
        public Integer Cantidad; // 10
        public Double Precio; // 1.1937
        public Integer DescuentoImporte; // 0
        public Integer Impuesto1; // 16
        public Double Costo; // 0.9586
        public String ContUso2; // "10"
        public String FechaRequerida; // "2025-11-21T00:00:00"
        public Boolean ThoDescAmpliada; // true
        public List<PedidosCta> PedidosCta;
    }

    public class PedidosCta {
        public String TipoSF; // "Pedido"
        public String DestinoMov; // "Pedido"
        public String DestinoMovID; // "MID14803"
        public String FechaPedido; // "2025-11-21T00:00:00"
        public String EstatusPedido; // "CONCLUIDO"
        public List<PedidosDetCta> PedidosDetCta;
    }

    public class PedidosDetCta {
        public Integer ID; // 224749
        public String aplica; // "Cotizacion"
        public String aplicaID; // "MID34400"
        public Integer aplicaRenglon; // 2048
        public String Articulo; // "EL-SOP0-0030"
        public Integer CantidadPedido; // 5
        public Double Precio; // 1.1937
        public Integer DescuentoImporte; // 0
    }

    public static ETC_AeiQuoteModel parse(String jsonString) {
        return (ETC_AeiQuoteModel) JSON.deserialize(jsonString, ETC_AeiQuoteModel.class);
    }
}
