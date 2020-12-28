package com.company;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

import static java.lang.Math.abs;
import static java.lang.Math.sqrt;

public class Main {

    public static void main(String[] args) {
        List<Cidade> lista = new ArrayList<>();

        try {

            BufferedReader br = new BufferedReader(new FileReader("cidades.csv"));

            String linha = br.readLine();
            linha = br.readLine();

            while (linha != null){
                String[] idk = linha.split(",");
                lista.add(new Cidade(idk[0],idk[1],Double.parseDouble(idk[2]),Double.parseDouble(idk[3]),idk[4],idk[5]));

                linha = br.readLine();


            }

            calculaLigações(lista);




        } catch (IOException e){
            e.printStackTrace();
        }


    }

    private static void calculaLigações(List<Cidade> lista){
        int checked = 0;
        double max = 0.5;
        double distance,y2,y1,x2,x1;
        for(Cidade c : lista){

            for(int i = lista.size()-1;i > checked;i--){

                Cidade tmp = lista.get(i);
                x2 = tmp.getLat();
                y2 = tmp.getLon();
                x1 = c.getLat();
                y1 = c.getLon();

                distance = abs(sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1)));
                if(distance < max){
                    c.addLigaçao(tmp.getId());
                    c.addDistancia(distance);
                }


            }
            checked++;

        }



        try {

            PrintWriter pr = new PrintWriter(new FileWriter("cidades_processadas.csv"));
            pr.println("iD,city,lat,lng,admin,capital,ligações");

            for(Cidade c: lista){
                pr.println(c.toString());
                pr.flush();
            }

        }catch (IOException e){
            e.printStackTrace();
        }




    }

}
