#ifndef FFT_H
#define FFT_H
extern void makeW(int num, int dir, double wR[], double wI[]);
extern void bit_reverse_swap(int num, double dR[], double dI[]);
extern void gen_data(int num_of_samples
                    ,char file_name_float[]
                    ,double floatR[], double floatI[]
                    ,char file_name_fixed[]
                    ,int16_t fixedR[], int16_t fixedI[]
                    ,int bitInt, int bitFrac);
extern void get_data(int num, char file_name[],
                     double wR[], double wI[]);
extern void put_data_fixed(int num, char file_name[], int bit_width
                          ,unsigned int wR[], unsigned int wI[]);
extern void put_data_float(int num, char file_name[]
                          ,int bit_int, int bit_frac   
                          ,unsigned int wR[], unsigned int wI[]);
extern void do_fft_dit_wtable(int num, int dir,
                              double dR[], double dI[],
                              double wR[], double wI[]);
extern void do_fft_dit_embedded(int num, int dir,
                                double dR[], double dI[]);
extern void do_fft_dif_wtable(int num, int dir,
                              double dR[], double dI[],
                              double wR[], double wI[]);
extern void do_fft_dif_embedded(int num, int dir,
                                double dR[], double dI[]);
#endif
