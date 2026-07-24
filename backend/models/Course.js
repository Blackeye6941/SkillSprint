const mongoose = require('mongoose');

// Resource Schema (YouTube & Docs)
const ResourceSchema = new mongoose.Schema({
  title: String,
  url: String,
}, { _id: false });

// Daily Task Schema
const TaskSchema = new mongoose.Schema({
  task_id: String,
  type: {
    type: String,
    enum: ['learning', 'practice', 'project', 'review'],
  },
  description: String,
  estimated_time_minutes: Number,
  completed: {
    type: Boolean,
    default: false,
  },
}, { _id: false });

// Daily Checkpoint Schema
const CheckpointSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ['self_check', 'quiz', 'mini_project'],
  },
  criteria: String,
}, { _id: false });

// Daily Plan Schema
const DailyPlanSchema = new mongoose.Schema({
  day: Number,
  title: String,
  description: String,
  learning_objectives: [String],
  tasks: [TaskSchema],
  resources: {
    youtube: [ResourceSchema],
    docs: [ResourceSchema],
  },
  checkpoint: CheckpointSchema,
}, { _id: false });

// Milestone Schema
const MilestoneSchema = new mongoose.Schema({
  milestone_id: String,
  title: String,
  goal: String,
  days: [Number],
}, { _id: false });

// Project Schema
const ProjectSchema = new mongoose.Schema({
  project_id: String,
  title: String,
  description: String,
  start_day: Number,
  end_day: Number,
  deliverables: [String],
}, { _id: false });

// Assessment Schema
const AssessmentSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ['final_project', 'test', 'presentation'],
  },
  criteria: [String],
}, { _id: false });

// Main Course / Roadmap Schema
const courseSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    roadmap_id: String,
    topic: {
      type: String,
      required: true,
    },
    total_days: Number,
    overview: {
      summary: String,
      final_outcome: String,
      prerequisites: [String],
    },
    milestones: [MilestoneSchema],
    daily_plan: [DailyPlanSchema],
    projects: [ProjectSchema],
    assessment: AssessmentSchema,
    metadata: {
      generated_at: String,
      model: String,
      version: String,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Course', courseSchema);
