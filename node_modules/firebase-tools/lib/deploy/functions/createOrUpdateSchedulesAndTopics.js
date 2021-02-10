"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createOrUpdateSchedulesAndTopics = void 0;
const _ = require("lodash");
const ensureApiEnabled_1 = require("../../ensureApiEnabled");
const functionsDeployHelper_1 = require("../../functionsDeployHelper");
const cloudscheduler_1 = require("../../gcp/cloudscheduler");
const pubsub_1 = require("../../gcp/pubsub");
async function createOrUpdateSchedulesAndTopics(projectId, triggers, existingScheduledFunctions, appEngineLocation) {
    const triggersWithSchedules = triggers.filter((t) => !!t.schedule);
    let schedulerEnabled = false;
    if (triggersWithSchedules.length) {
        await Promise.all([
            ensureApiEnabled_1.ensure(projectId, "cloudscheduler.googleapis.com", "scheduler", false),
            ensureApiEnabled_1.ensure(projectId, "pubsub.googleapis.com", "pubsub", false),
        ]);
        schedulerEnabled = true;
    }
    else if (existingScheduledFunctions.length) {
        schedulerEnabled = await ensureApiEnabled_1.check(projectId, "cloudscheduler.googleapis.com", "scheduler", false);
    }
    for (const trigger of triggers) {
        const [, , , region, , functionName] = trigger.name.split("/");
        const scheduleName = functionsDeployHelper_1.getScheduleName(trigger.name, appEngineLocation);
        const topicName = functionsDeployHelper_1.getTopicName(trigger.name);
        if (!trigger.schedule) {
            if (schedulerEnabled && _.includes(existingScheduledFunctions, trigger.name)) {
                try {
                    await cloudscheduler_1.deleteJob(scheduleName);
                }
                catch (err) {
                    if (err.context.response.statusCode !== 404) {
                        throw err;
                    }
                }
                try {
                    await pubsub_1.deleteTopic(topicName);
                }
                catch (err) {
                    if (err.context.response.statusCode !== 404) {
                        throw err;
                    }
                }
            }
        }
        else {
            await cloudscheduler_1.createOrReplaceJob(Object.assign(trigger.schedule, {
                name: `projects/${projectId}/locations/${appEngineLocation}/jobs/firebase-schedule-${functionName}-${region}`,
                pubsubTarget: {
                    topicName: `projects/${projectId}/topics/firebase-schedule-${functionName}-${region}`,
                    attributes: {
                        scheduled: "true",
                    },
                },
            }));
        }
    }
    return;
}
exports.createOrUpdateSchedulesAndTopics = createOrUpdateSchedulesAndTopics;
