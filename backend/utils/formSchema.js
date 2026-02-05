const { Type } = require("@google/genai");

const formSchema = {
  type: Type.OBJECT,
  properties: {
    roadmap_id: { type: Type.STRING },

    user_id: { type: Type.STRING },

    topic: { type: Type.STRING },

    total_days: { type: Type.NUMBER },

    overview: {
      type: Type.OBJECT,
      properties: {
        summary: { type: Type.STRING },
        final_outcome: { type: Type.STRING },
        prerequisites: {
          type: Type.ARRAY,
          items: { type: Type.STRING },
        },
      },
      propertyOrdering: ["summary", "final_outcome", "prerequisites"],
    },

    milestones: {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          milestone_id: { type: Type.STRING },
          title: { type: Type.STRING },
          goal: { type: Type.STRING },
          days: {
            type: Type.ARRAY,
            items: { type: Type.NUMBER },
          },
        },
        propertyOrdering: ["milestone_id", "title", "goal", "days"],
      },
    },

    daily_plan: {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          day: { type: Type.NUMBER },

          title: { type: Type.STRING },

          description: { type: Type.STRING },

          learning_objectives: {
            type: Type.ARRAY,
            items: { type: Type.STRING },
          },

          tasks: {
            type: Type.ARRAY,
            items: {
              type: Type.OBJECT,
              properties: {
                task_id: { type: Type.STRING },
                type: {
                  type: Type.STRING,
                  enum: ["learning", "practice", "project", "review"],
                },
                description: { type: Type.STRING },
                estimated_time_minutes: { type: Type.NUMBER },
                completed: { type: Type.BOOLEAN },
              },
              propertyOrdering: [
                "task_id",
                "type",
                "description",
                "estimated_time_minutes",
                "completed",
              ],
            },
          },

          resources: {
            type: Type.OBJECT,
            properties: {
              youtube: {
                type: Type.ARRAY,
                items: {
                  type: Type.OBJECT,
                  properties: {
                    title: { type: Type.STRING },
                    url: { type: Type.STRING },
                  },
                  propertyOrdering: ["title", "url"],
                },
              },
              docs: {
                type: Type.ARRAY,
                items: {
                  type: Type.OBJECT,
                  properties: {
                    title: { type: Type.STRING },
                    url: { type: Type.STRING },
                  },
                  propertyOrdering: ["title", "url"],
                },
              },
            },
            propertyOrdering: ["youtube", "docs"],
          },

          checkpoint: {
            type: Type.OBJECT,
            properties: {
              type: {
                type: Type.STRING,
                enum: ["self_check", "quiz", "mini_project"],
              },
              criteria: { type: Type.STRING },
            },
            propertyOrdering: ["type", "criteria"],
          },
        },
        propertyOrdering: [
          "day",
          "title",
          "description",
          "learning_objectives",
          "tasks",
          "resources",
          "checkpoint",
        ],
      },
    },

    projects: {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          project_id: { type: Type.STRING },
          title: { type: Type.STRING },
          description: { type: Type.STRING },
          start_day: { type: Type.NUMBER },
          end_day: { type: Type.NUMBER },
          deliverables: {
            type: Type.ARRAY,
            items: { type: Type.STRING },
          },
        },
        propertyOrdering: [
          "project_id",
          "title",
          "description",
          "start_day",
          "end_day",
          "deliverables",
        ],
      },
    },

    assessment: {
      type: Type.OBJECT,
      properties: {
        type: {
          type: Type.STRING,
          enum: ["final_project", "test", "presentation"],
        },
        criteria: {
          type: Type.ARRAY,
          items: { type: Type.STRING },
        },
      },
      propertyOrdering: ["type", "criteria"],
    },

    metadata: {
      type: Type.OBJECT,
      properties: {
        generated_at: { type: Type.STRING },
        model: { type: Type.STRING },
        version: { type: Type.STRING },
      },
      propertyOrdering: ["generated_at", "model", "version"],
    },
  },

  propertyOrdering: [
    "roadmap_id",
    "user_id",
    "topic",
    "total_days",
    "overview",
    "milestones",
    "daily_plan",
    "projects",
    "assessment",
    "metadata",
  ],
};

module.export = formSchema;

