#!/bin/bash
#SBATCH -p mid
#SBATCH -J inf
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 10
#SBATCH --gres=gpu:1
#SBATCH --constraint=v100
#SBATCH --time=1-00:00:00

module load cuda-10.2.89-gcc-10.2.0-dgnsc3t

echo "SLURM_NODELIST $SLURM_NODELIST"
echo "NUMBER OF CORES $SLURM_NTASKS"
echo "CUDA DEVICES $CUDA_VISIBLE_DEVICES"

HOME_DIR=/cta/users/bbaykara/code/enc_dec_sum
RESULTS_FOLDER=results
MODELS_FOLDER=outputs
TASK_NAME=title

for MODEL_NAME in tr_news_mt5_title/checkpoint-52044 ml_sum_mt5_title/checkpoint-38950 combined_tr_mt5_title/checkpoint-98784
do
  for DATASET_NAME in tr_news_raw ml_sum_tr_raw combined_tr_raw
  do
    OUTPUTS_PATH=$HOME_DIR/$RESULTS_FOLDER/cross_dataset/$TASK_NAME/$MODEL_NAME/$DATASET_NAME
    mkdir -p $OUTPUTS_PATH
    echo $OUTPUTS_PATH

    if [[ "$DATASET_NAME" == *"tr_news"* ]]; then
      $HOME_DIR/venv/bin/python $HOME_DIR/post_metrics.py \
      --model_name_or_path $HOME_DIR/$MODELS_FOLDER/$MODEL_NAME \
      --dataset_test_csv_file_path $HOME_DIR/data/$DATASET_NAME/test.csv \
      --text_outputs_file_path $OUTPUTS_PATH/text_outputs.csv \
      --rouge_outputs_file_path $OUTPUTS_PATH/rouge_outputs.json \
      --novelty_outputs_file_path $OUTPUTS_PATH/novely_outputs.json \
      --do_tr_lowercase True \
      --source_column_name abstract \
      --target_column_name title \
      --source_prefix "summarize: " \
      --num_beams 4 \
      --ngram_blocking_size 3 \
      --early_stopping False \
      --use_cuda True \
      --max_source_length 256 \
      --max_target_length 64 \
      --batch_size 16 \
      --use_stemmer_in_rouge False
    else
      $HOME_DIR/venv/bin/python $HOME_DIR/post_metrics.py \
      --model_name_or_path $HOME_DIR/$MODELS_FOLDER/$MODEL_NAME \
      --dataset_test_csv_file_path $HOME_DIR/data/$DATASET_NAME/test.csv \
      --text_outputs_file_path $OUTPUTS_PATH/text_outputs.csv \
      --rouge_outputs_file_path $OUTPUTS_PATH/rouge_outputs.json \
      --novelty_outputs_file_path $OUTPUTS_PATH/novely_outputs.json \
      --do_tr_lowercase True \
      --source_column_name summary \
      --target_column_name title \
      --source_prefix "summarize: " \
      --num_beams 4 \
      --ngram_blocking_size 3 \
      --early_stopping False \
      --use_cuda True \
      --max_source_length 256 \
      --max_target_length 64 \
      --batch_size 16 \
      --use_stemmer_in_rouge False
    fi
  done
done

TASK_NAME=title_first3

for MODEL_NAME in tr_news_mt5_title_first3/checkpoint-52044 ml_sum_mt5_title_first3/checkpoint-38950 combined_tr_mt5_title_first3/checkpoint-98784
do
  for DATASET_NAME in tr_news_raw ml_sum_tr_raw combined_tr_raw
  do
    OUTPUTS_PATH=$HOME_DIR/$RESULTS_FOLDER/cross_dataset/$TASK_NAME/$MODEL_NAME/$DATASET_NAME
    mkdir -p $OUTPUTS_PATH
    echo $OUTPUTS_PATH

    $HOME_DIR/venv/bin/python $HOME_DIR/post_metrics.py \
    --model_name_or_path $HOME_DIR/$MODELS_FOLDER/$MODEL_NAME \
    --dataset_test_csv_file_path $HOME_DIR/data/$DATASET_NAME/test.csv \
    --text_outputs_file_path $OUTPUTS_PATH/text_outputs.csv \
    --rouge_outputs_file_path $OUTPUTS_PATH/rouge_outputs.json \
    --novelty_outputs_file_path $OUTPUTS_PATH/novely_outputs.json \
    --do_tr_lowercase True \
    --source_column_name first3 \
    --target_column_name title \
    --source_prefix "summarize: " \
    --num_beams 4 \
    --ngram_blocking_size 3 \
    --early_stopping False \
    --use_cuda True \
    --max_source_length 256 \
    --max_target_length 64 \
    --batch_size 16 \
    --use_stemmer_in_rouge False
  done
done
