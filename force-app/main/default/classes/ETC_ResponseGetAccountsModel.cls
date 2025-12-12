public class ETC_ResponseGetAccountsModel {
    public Meta meta;
    public List<Data> data;

    public class Meta {
        public Integer page; // 5
        public Integer limit_cst; // 1
    }

    public class Data {
        public String Cliente; // "1000"
        public String Nombre; // "COLONOS LUM ZAMA ARTILA"
        public String Direccion; // "AV. SAYIL MANZANA 5 LOTE 2 PH8 SM6 Entre Calle...
        public String DireccionNumero;
        public String EntreCalles;
        public String Delegacion; // "Tulum"
        public String Colonia; // "Tulum Centro"
        public String Poblacion;
        public String Estado; // "Quintana Roo"
        public String Pais; // "México"
        public String CodigoPostal; // "77760"
        public String RFC; // "CLZ191015MG3"
        public String eMail1;
        public String Credito;
        public String ZonaImpuesto; // "IVA 0 a 16"
        public String Agente; // "CHERNANDEZ"
        public String Condicion;
        public String ListaPreciosEsp;
        public String Estatus; // "ALTA"
        public List<Contactos> contactos;
    }

    public class Contactos {
        public String Cliente; // "1000"
        public Integer ID; // 1258
        public String Nombre; // "FACTURACION"
        public String eMail; // "administracion@artila.mx"
    }

    public static ETC_ResponseGetAccountsModel parse(String jsonString) {
        jsonString = jsonString.replace('"limit"', '"limit_cst"');
        return (ETC_ResponseGetAccountsModel) JSON.deserialize(jsonString, ETC_ResponseGetAccountsModel.class);
    }
}
