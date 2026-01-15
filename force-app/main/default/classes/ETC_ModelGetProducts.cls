public class ETC_ModelGetProducts {
    public Meta meta;
    public List<Data> data;

    public class Meta {
        public Integer page; // 15
        public Integer limit_cst; // 2
    }

    public class Data {
        public String Articulo; // "-AC-CCH0-1351 "
        public String Rama; // "IL0204"
        public String Descripcion1; // "Luminaria serie champ led tipo reflector para ...
        public String Grupo; // "Nuevo"
        public String Categoria; // "Areas clasificadas"
        public String Familia; // "Iluminacion"
        public String Linea; // "Profesional"
        public String Fabricante; // "Cooper Crouse Hinds"
        public String ClaveFabricante; // "-FMVA25LCY-UNV34-76"
        public Integer Impuesto1; // 16
        public String Unidad; // "PZ"
        public String TipoCosteo; // "Promedio"
        public Double Peso; // 16.55
        public String Tipo; // "Normal"
        public String MonedaCosto; // "Pesos"
        public String MonedaPrecio; // "Pesos"
        public Integer MargenMinimo; // 20
        public String Estatus; // "ALTA"
        public String UltimoCambio; // "2023-12-14T17:40:41.000Z"
        public String Alta; // "2023-12-14T17:40:24.000Z"
        public String Usuario; // "JRIVAS"
        public String AlmacenROP; // "001MERIDA"
        public String RevisionUsuario; // "JRIVAS"
        public String TipoCompra; // "Centralizada"
        public Boolean TieneMovimientos; // true
        public String RutaDistribucion; // "Matriz-Sucursales"
        public String Proveedor; // "232"
        public String ContUso2; // "10"
        public List<Artcosto> artcosto;
        public List<Artdisponible> artdisponible;
    }

    public class Artcosto {
        public Integer Sucursal; // 1
        public Double UltimoCosto; // 0
        public Double CostoPromedio; // 29788.1
    }

    public class Artdisponible {
        public String Almacen; // "01PEMEX   "
        public Double Existencias; // 0
        public Double Apartado; // 0
        public Double Disponible; // 0
    }

    public static ETC_ModelGetProducts parse(String jsonString) {
        return (ETC_ModelGetProducts) JSON.deserialize(jsonString, ETC_ModelGetProducts.class);
    }
}