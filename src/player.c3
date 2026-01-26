/*
Tässä on esimerkki siitä, miten koodia voi jakaa moneen tiedostoon. Projektin ollessa
alkuvaiheessa, tämä on hieman turhaa, mutta jatkossa voi olla mukavaa luokitella koodia
omiin tiedostoihinsa. Tässä nyt esimerkiksi tidosto, johon tulee kaikki ensisijaisesti
pelaajaan liittyvät asiat.
*/
module working_title;

struct Player
{
	Vec2 position;
    float speed;
}