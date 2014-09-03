
Maxim maxim;
AudioPlayer[] player;

int counter;
int startSecond;
int minute = 0;
boolean check_minute = true;

float speed;
float alpha;

// Ambient sound
int SOUND_AMB0 = 0; // at the beginning, looping
int SOUND_AMB1 = 1; // starts at second 30, looping
int SOUND_AMB2 = 2; // after the first minute, played at seconds 0 and 30

// These sounds are randomly played at seconds 15th and 45th:
int SOUND_WHALE          = 3;
int SOUND_THUNDER        = 4;
int SOUND_GEIGER_COUNTER = 5;
int SOUND_OLD_RADIO      = 6;
int SOUND_GO_AT          = 7;

// Random sounds to choose from
int SOUND_RAND_FIRST = 3;
int SOUND_LAST  = 7;

// Somr info about the current random sound
int random_sound = 0;
boolean random_sound_playing = false;

// Cellular automata
int Rx, Ry;
int[][] cell, aux;
int color_phase = 0;


void setup() {
    size( 600, 900 );
    background( 0 );
    rectMode( CENTER );
    colorMode( HSB, 255 );

    Rx = 20;
    Ry = 20;

    cell = new int[Rx][Ry];
    aux = new int[Rx][Ry];

    for ( int j = 0; j < Ry; j++ ) {
        for ( int i = 0; i < Rx; i++ ) {
            cell[i][j] = int( random( 22, 32 ));
            aux[i][j] = cell[i][j];
        }
    }

    maxim = new Maxim( this );
    player = new AudioPlayer[SOUND_LAST+1];

    player[SOUND_AMB0] = maxim.loadFile( "183881__erokia__elementary-wave-11.wav" );
    player[SOUND_AMB0].setLooping( true );
    player[SOUND_AMB0].volume( 1.0 );
    player[SOUND_AMB0].setAnalysing( true );

    player[SOUND_AMB1] = maxim.loadFile( "22335__dj-chronos__ambient-darkness.wav" );
    player[SOUND_AMB1].setLooping( true );
    player[SOUND_AMB1].volume( 1.0 );

    player[SOUND_AMB2] = maxim.loadFile( "52037__striptheband__ambient-groove-019.wav" );
    player[SOUND_AMB2].setLooping( false );
    player[SOUND_AMB2].volume( 0.6 );
    player[SOUND_AMB2].setAnalysing( true );

    player[SOUND_WHALE] = maxim.loadFile( "186899__tritus__whale.wav" );
    player[SOUND_WHALE].setLooping( false );
    player[SOUND_WHALE].volume( 1.0 );
    player[SOUND_WHALE].setAnalysing( true );

    player[SOUND_THUNDER] = maxim.loadFile( "24952__erdie__thunder-long-distance.wav" );
    player[SOUND_THUNDER].setLooping( false );
    player[SOUND_THUNDER].volume( 0.7 );
    player[SOUND_THUNDER].setAnalysing( true );

    player[SOUND_GEIGER_COUNTER] = maxim.loadFile( "161653__qubodup__radioactive-levelup.wav" );
    player[SOUND_GEIGER_COUNTER].setLooping( false );
    player[SOUND_GEIGER_COUNTER].volume( 0.5 );
    player[SOUND_GEIGER_COUNTER].setAnalysing( true );

    player[SOUND_OLD_RADIO] = maxim.loadFile( "27510__drni__old-radio-noise-defective-medium-wave-2.wav" );
    player[SOUND_OLD_RADIO].setLooping( false );
    player[SOUND_OLD_RADIO].volume( 0.7 );
    player[SOUND_OLD_RADIO].setAnalysing( true );

    player[SOUND_GO_AT] = maxim.loadFile( "80559__bigvin88__ambientgoat.wav" );
    player[SOUND_GO_AT].setLooping( false );
    player[SOUND_GO_AT].volume( 0.9 );
    player[SOUND_GO_AT].setAnalysing( true );

    startSecond = ( second() - 1 ) % 60;
    print( "startSecond = " + startSecond + "\n" );
}

void update() {
    speed = dist( pmouseX, pmouseY, mouseX, mouseY );
    alpha = map( speed, 0, 20, 5, 20 );
}

void fadeBackground() {
    noStroke();
    fill( 0, alpha );
    rect( width/2, height/2, width, height );
}

void playSound()
{
    if ( startSecond - second() == 0 ) {
        if ( check_minute ) {
            minute++;
            print( "minute = " + minute + "\n" );
            check_minute = false;
        }
    }
    else
        check_minute = true;

    player[SOUND_AMB0].play();

    if (( ! player[SOUND_AMB1].isPlaying()) &&
        ( abs( second() - startSecond ) == 30 )) {
        player[SOUND_AMB1].play();
        print( "player[SOUND_AMB1].play\n" );
    }

    int second = second();
    if (( minute >= 1 ) &&
        ( second == 0 || second == 30 )) {
        if ( ! player[SOUND_AMB2].isPlaying()) {
            player[SOUND_AMB2].play();
            print( "player[SOUND_AMB2].play\n" );
        }
    }

    if ( //.debug ( minute >= 1 ) &&
    ( second == 15 || second == 45 )) {
        if ( ! random_sound_playing ) {
            random_sound = int( random( SOUND_RAND_FIRST, SOUND_LAST+1 ));
            player[random_sound].play();
            player[random_sound].setAnalysing( true );
            print( "player[" + random_sound + "].play\n" );
            random_sound_playing = true;
        }
    }
    else
        random_sound_playing = false;
}

void draw_cells() {

    noStroke();
    float speed = dist( pmouseX, pmouseY, mouseX, mouseY );
    float alpha = map( speed, 0, 20, 20, 50 );
    fill( 0, alpha );
    //rect( width/2, height/2, width, height );

    stroke( 255, 255, 255);
    strokeWeight( 2 );

    for ( int j = 0; j < Ry; j++ ) {
        int jm1 = (j-1)%Ry, jp1 = (j+1)%Ry;
        if ( jm1 <0 ) jm1 = Ry-1;
        for ( int i = 0; i < Rx; i++ ) {
            aux[i][j] = cell[i][j];
            int im1 = (i-1)%Rx, ip1 = (i+1)%Rx;
            if ( im1 < 0 ) im1 = Rx-1;
            int s = ( cell[im1][jm1] < 64 ? 0 : 1 ) +
                ( cell[i][jm1]   < 64 ? 0 : 1 ) +
                ( cell[ip1][jm1] < 63 ? 0 : 1 ) +
                ( cell[im1][j]   < 64 ? 0 : 1 ) +
                ( cell[ip1][j]   < 64 ? 0 : 1 ) +
                ( cell[im1][jp1] < 64 ? 0 : 1 ) +
                ( cell[i][jp1]   < 64 ? 0 : 1 ) +
                ( cell[ip1][jp1] < 64 ? 0 : 1 );
            if ( cell[i][j] < 64 ) { // is dead
                if ( 2 == s || s == 3 ) { // 2-3 live neightbors
                    aux[i][j] = 65;
                }
            }
            else {
                if ( s < 2 || s > 3 )
                    aux[i][j] = cell[i][j]-0;
            }
        }
    }

    float wr = width/Rx, hr = height/Ry;
    for ( int j = 0; j < Ry; j++ ) {
        for ( int i = 0; i < Rx; i++ ) {
            cell[i][j] = aux[i][j];
            cell[i][j] -= ( cell[i][j] > 60 ? 2 :
            cell[i][j] > 32 ? random( 10 ) : 0 );
            // filled cell
            stroke( 0, 0, 0 );
            strokeWeight( 2 );
            int hue = color_phase + i*j;
            fill( hue%255, 
                  map( cell[i][j], 32, 255, 100, 128 ), 
                  cell[i][j] );

            rect( wr/2+wr*i, hr/2+hr*j, wr, hr );
        }
    }
}

float prev_h = 0.0;
int rand_i = 0;
int rand_j = 0;
void draw() {
    
    draw_cells();
    
    counter++;

    update();
    fadeBackground();

    playSound();

    if ( random_sound_playing ) {
        color_phase += 5;
        if( rand_i == 0 ) {
            rand_i = int( random( 3, Rx-3 ));
            rand_j = int( random( 3, Ry-3 ));
        }
        cell[rand_i][rand_j] += random( 0, 20 );
        cell[rand_i+1][rand_j+1] += random( 0, 10 );
        cell[rand_i+1][rand_j-1] += random( 0, 10 );
        cell[rand_i-1][rand_j+1] += random( 0, 10 );
        cell[rand_i-1][rand_j-1] += random( 0, 10 );
    }
    else
        rand_i = 0;
}

void mouseMoved()
{
    color_phase++;
    float wr = width/Rx, hr = height/Ry;
    int i = min( floor( pmouseX / wr ), Rx-1 );
    int j = min( floor( pmouseY / hr ), Ry-1 );
    cell[i][j] += ( cell[i][j] < 236 ? 20 : 0 );
    //aux[i][j] = cell[i][j];

    i = min( floor( mouseX / wr ), Rx-1 );
    j = min( floor( mouseY / hr ), Ry-1 );
    cell[i][j] += ( cell[i][j] < 226 ? 30 : 0 );
    //aux[i][j] = cell[i][j];
}

void mouseDragged()
{
    color_phase++;
    float wr = width/Rx, hr = height/Ry;
    int i = min( floor( pmouseX / wr ), Rx-1 );
    int j = min( floor( pmouseY / hr ), Ry-1 );
    cell[i][j] += ( cell[i][j] < 235 ? 30 : 0 );

    i = min( floor( mouseX / wr ), Rx-1 );
    j = min( floor( mouseY / hr ), Ry-1 );
    cell[i][j] += ( cell[i][j] < 225 ? 30 : 0 );

    i--; 
    if ( i < 0 ) i = 0;
    j--; 
    if ( j < 0 ) j = 0;
    cell[i][j] += ( cell[i][j] < 225 ? 30 : 0 );
    cell[i++][j] += ( cell[i][j] < 225 ? 30 : 0 );
    cell[i][j++] += ( cell[i][j] < 225 ? 30 : 0 );
}
