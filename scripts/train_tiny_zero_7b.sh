export N_GPUS=4
export BASE_MODEL=Qwen/Qwen2.5-7B
export DATA_DIR=/home/zhangchunhui/data/countdown/
export ROLLOUT_TP_SIZE=2
export EXPERIMENT_NAME=countdown-qwen2.5-7b-ppo
export VLLM_ATTENTION_BACKEND=XFORMERS

python3 -m verl.trainer.main_ppo \
    data.train_files=$DATA_DIR/train.parquet \
    data.val_files=$DATA_DIR/test.parquet \
    data.train_batch_size=256 \
    data.val_batch_size=1312 \
    data.max_prompt_length=256 \
    data.max_response_length=1024 \
    actor_rollout_ref.model.path=$BASE_MODEL \
    actor_rollout_ref.model.enable_gradient_checkpointing=True \
    actor_rollout_ref.model.use_remove_padding=True \
    actor_rollout_ref.actor.use_dynamic_bsz=True \
    actor_rollout_ref.actor.optim.lr=1e-6 \
    actor_rollout_ref.actor.ppo_mini_batch_size=64 \
    actor_rollout_ref.actor.ppo_micro_batch_size=8 \
    actor_rollout_ref.rollout.log_prob_micro_batch_size=8 \
    actor_rollout_ref.rollout.tensor_model_parallel_size=$ROLLOUT_TP_SIZE \
    actor_rollout_ref.rollout.gpu_memory_utilization=0.6 \
    actor_rollout_ref.ref.log_prob_micro_batch_size=4 \
    critic.model.enable_gradient_checkpointing=True \
    critic.optim.lr=1e-5 \
    critic.model.path=$BASE_MODEL \
    critic.ppo_micro_batch_size=8 \
    algorithm.kl_ctrl.kl_coef=0.001 \
    trainer.logger=['wandb'] \
    +trainer.val_before_train=True \
    trainer.default_hdfs_dir=null \
    trainer.n_gpus_per_node=$N_GPUS \
    trainer.nnodes=1 \
    trainer.save_freq=200 \
    trainer.test_freq=5 \
    trainer.project_name=rl4llm \
    trainer.experiment_name=$EXPERIMENT_NAME \
    trainer.total_epochs=15 2>&1 | tee verl_demo.log
