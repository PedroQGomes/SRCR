package com.company;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class Cidade {

    private String id;
    private String nome;
    private double lat;
    private  double lon;
    private String admin;
    private String capital;
    private List<String> ligações;
    private List<Double> distancia;

    public Cidade(String id, String nome, double lat, double lon, String admin, String capital) {
        this.id = id;
        this.nome = nome;
        this.lat = lat;
        this.lon = lon;
        this.admin = admin;
        this.capital = capital;
        this.ligações = new ArrayList<>();
        this.distancia = new ArrayList<>();

    }

    public String getId() {
        return id;
    }

    public String getNome() {
        return nome;
    }

    public double getLat() {
        return lat;
    }

    public double getLon() {
        return lon;
    }

    public String getAdmin() {
        return admin;
    }

    public String getCapital() {
        return capital;
    }

    public List<String> getLigações() {
        return ligações;
    }

    public void addLigaçao(String l) {
        this.ligações.add(l);
    }

    public void addDistancia(Double d) {
        this.distancia.add(d);
    }

    /*
    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(this.id).append(",");
        sb.append(this.nome).append(",");
        sb.append(this.lat).append(",");
        sb.append(this.lon).append(",");
        sb.append(this.admin).append(",");
        sb.append(this.capital).append(",");
        sb.append(sringBuilderLista());

        return sb.toString();
    }

    private String sringBuilderLista(){
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        sb.append(ligações.get(0));
        for(int i = 1; i < ligações.size();i++){

            sb.append(",");
            sb.append(ligações.get(i));

        }
        sb.append("]");
        return sb.toString();

    }

    */

    @Override
    public String toString() {

        StringBuilder sb = new StringBuilder();

        for(int i = 0; i < ligações.size();i++){
            sb.append(this.id);
            sb.append(",");
            sb.append(ligações.get(i));
            sb.append(",");
            sb.append(distancia.get(i));
            if(i != ligações.size()-1)sb.append("\n");

        }
        return sb.toString();


    }





}
