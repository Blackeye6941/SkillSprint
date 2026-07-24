const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const connectDB = require('./config/db.js');
const User = require('./models/User.js');
const Course = require('./models/Course.js');
const auth = require('./middleware/auth.js');
const { generateRoadmap } = require('./agent.js');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'skillsprint_super_secret_jwt_key_2026';

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Connect to MongoDB
connectDB();

// Helper function to generate JWT Token
const generateToken = (id, email) => {
	return jwt.sign({ id, email }, JWT_SECRET, { expiresIn: '30d' });
};

app.get('/', (req, res) => {
	res.send("<h1>SkillSprint Backend (Auth & Ownership Protection Active)</h1>");
});

// ==================== AUTHENTICATION ROUTES ====================

// @route   POST /api/auth/register
// @desc    Register a new user & get JWT token
app.post('/api/auth/register', async (req, res) => {
	try {
		const { name, email, password } = req.body;

		if (!name || !email || !password) {
			return res.status(400).json({ success: false, error: 'Name, email, and password (min 6 chars) are required.' });
		}

		// Check if user exists
		const userExists = await User.findOne({ email });
		if (userExists) {
			return res.status(400).json({ success: false, error: 'User already exists with this email.' });
		}

		const user = await User.create({ name, email, password });
		const token = generateToken(user._id, user.email);

		res.status(201).json({
			success: true,
			user: {
				id: user._id,
				name: user.name,
				email: user.email,
			},
			token
		});
	} catch (error) {
		res.status(500).json({ success: false, error: error.message });
	}
});

// @route   POST /api/auth/login
// @desc    Authenticate user & get JWT token
app.post('/api/auth/login', async (req, res) => {
	try {
		const { email, password } = req.body;

		if (!email || !password) {
			return res.status(400).json({ success: false, error: 'Email and password are required.' });
		}

		const user = await User.findOne({ email });
		if (user && (await user.matchPassword(password))) {
			const token = generateToken(user._id, user.email);
			return res.json({
				success: true,
				user: {
					id: user._id,
					name: user.name,
					email: user.email,
				},
				token
			});
		} else {
			return res.status(401).json({ success: false, error: 'Invalid email or password.' });
		}
	} catch (error) {
		res.status(500).json({ success: false, error: error.message });
	}
});

// @route   GET /api/auth/me
// @desc    Get logged in user profile (Protected)
app.get('/api/auth/me', auth, async (req, res) => {
	try {
		const user = await User.findById(req.user.id).select('-password');
		if (!user) {
			return res.status(404).json({ success: false, error: 'User not found.' });
		}
		res.json({ success: true, user });
	} catch (error) {
		res.status(500).json({ success: false, error: error.message });
	}
});

// ==================== PROTECTED COURSE ROUTES ====================

// @route   POST /api/courses/generate
// @desc    Generate & Store Course for the LOGGED-IN User (Protected)
app.post('/api/courses/generate', auth, async (req, res) => {
	const { query } = req.body;

	if (!query) {
		return res.status(400).json({ success: false, error: 'Query prompt is required.' });
	}

	try {
		// Generate JSON from Gemini AI Agent
		const rawJsonText = await generateRoadmap({ prompt: query });
		const roadmapData = JSON.parse(rawJsonText);

		let milestones = Array.isArray(roadmapData.milestones) ? roadmapData.milestones : [];
		let daily_plan = Array.isArray(roadmapData.daily_plan) ? roadmapData.daily_plan : [];
		let projects = Array.isArray(roadmapData.projects) ? roadmapData.projects : [];

		// Handle case where Gemini returns an array of days directly
		if (Array.isArray(roadmapData) && daily_plan.length === 0) {
			daily_plan = roadmapData.map((d, i) => ({
				day: d.day || i + 1,
				title: d.title || d.topic || `Day ${i + 1}`,
				description: d.description || d.explanation || '',
				learning_objectives: d.learning_objectives || [d.title || d.topic || `Master Day ${i + 1} concepts`],
				tasks: (d.tasks || []).map((t, tid) => typeof t === 'string' ? {
					task_id: `t_${i+1}_${tid+1}`,
					type: 'learning',
					description: t,
					estimated_time_minutes: 30,
					completed: false
				} : t),
				resources: {
					youtube: (d.resources || []).filter(r => typeof r === 'string' ? (r.includes('youtube') || r.includes('youtu.be')) : (r.url?.includes('youtube') || r.url?.includes('youtu.be'))).map(r => typeof r === 'string' ? { title: 'Video Tutorial', url: r } : r),
					docs: (d.resources || []).filter(r => typeof r === 'string' ? (!r.includes('youtube') && !r.includes('youtu.be')) : (!r.url?.includes('youtube') && !r.url?.includes('youtu.be'))).map(r => typeof r === 'string' ? { title: 'Documentation', url: r } : r)
				},
				checkpoint: d.checkpoint || { type: 'self_check', criteria: `Complete all tasks for Day ${i + 1}` }
			}));
		}

		// Auto-generate Milestones if empty
		if (milestones.length === 0 && daily_plan.length > 0) {
			milestones = [
				{
					milestone_id: "m1",
					title: "Core Foundations",
					goal: "Master foundational concepts and initial hands-on practice",
					days: daily_plan.map(d => d.day)
				}
			];
		}

		// Auto-generate Projects if empty
		if (projects.length === 0 && daily_plan.length > 0) {
			projects = [
				{
					project_id: "p1",
					title: `${query} Capstone Project`,
					description: `Build a comprehensive practical project putting into practice all topics covered in this roadmap.`,
					start_day: 1,
					end_day: daily_plan.length,
					deliverables: ["Functional project codebase", "Documentation and README"]
				}
			];
		}

		// Save Course in MongoDB linked directly to the authenticated user's ID
		const newCourse = await Course.create({
			userId: req.user.id,
			topic: roadmapData.topic || query,
			total_days: roadmapData.total_days || daily_plan.length,
			overview: roadmapData.overview || {
				summary: `Comprehensive roadmap covering ${query}`,
				final_outcome: `Proficiency in ${query}`,
				prerequisites: []
			},
			milestones,
			daily_plan,
			projects,
			assessment: roadmapData.assessment || {
				type: "final_project",
				criteria: ["Completion of daily tasks", "Working project deliverable"]
			},
			metadata: roadmapData.metadata || {
				generated_at: new Date().toISOString(),
				model: "gemini-3-flash-preview",
				version: "1.0.0"
			}
		});

		res.status(201).json({
			success: true,
			message: "Course generated and stored successfully",
			course: newCourse
		});
	} catch (error) {
		console.error("Error generating course:", error);
		res.status(500).json({ success: false, error: error.message });
	}
});

// @route   GET /api/courses
// @desc    Get all courses belonging to the LOGGED-IN User (Protected)
app.get('/api/courses', auth, async (req, res) => {
	try {
		const courses = await Course.find({ userId: req.user.id }).sort({ createdAt: -1 });
		res.json({ success: true, count: courses.length, courses });
	} catch (error) {
		res.status(500).json({ success: false, error: error.message });
	}
});

// @route   GET /api/courses/:courseId
// @desc    Get a single course details ONLY if owned by LOGGED-IN User (Protected & Authorized)
app.get('/api/courses/:courseId', auth, async (req, res) => {
	try {
		const course = await Course.findById(req.params.courseId).populate('userId', 'name email');
		
		if (!course) {
			return res.status(404).json({ success: false, error: "Course not found." });
		}

		// 🔒 BACKEND OWNERSHIP SECURITY CHECK
		if (course.userId._id.toString() !== req.user.id) {
			return res.status(403).json({ success: false, error: "Access Denied: You do not own this course." });
		}

		res.json({ success: true, course });
	} catch (error) {
		res.status(500).json({ success: false, error: error.message });
	}
});

// @route   DELETE /api/courses/:courseId
// @desc    Delete a course ONLY if owned by LOGGED-IN User (Protected & Authorized)
app.delete('/api/courses/:courseId', auth, async (req, res) => {
	try {
		const course = await Course.findById(req.params.courseId);

		if (!course) {
			return res.status(404).json({ success: false, error: "Course not found." });
		}

		// 🔒 BACKEND OWNERSHIP SECURITY CHECK
		if (course.userId.toString() !== req.user.id) {
			return res.status(403).json({ success: false, error: "Access Denied: You cannot delete a course you do not own." });
		}

		await course.deleteOne();
		res.json({ success: true, message: "Course deleted successfully." });
	} catch (error) {
		res.status(500).json({ success: false, error: error.message });
	}
});

// @route   PATCH /api/courses/:courseId/tasks/:taskId
// @desc    Toggle completion status of a daily task (Protected & Authorized)
app.patch('/api/courses/:courseId/tasks/:taskId', auth, async (req, res) => {
	try {
		const { courseId, taskId } = req.params;
		const { completed } = req.body;

		const course = await Course.findById(courseId);

		if (!course) {
			return res.status(404).json({ success: false, error: "Course not found." });
		}

		// 🔒 BACKEND OWNERSHIP SECURITY CHECK
		if (course.userId.toString() !== req.user.id) {
			return res.status(403).json({ success: false, error: "Access Denied: You do not own this course." });
		}

		let taskFound = null;

		// Search across daily_plan tasks
		for (const plan of course.daily_plan) {
			if (plan.tasks && plan.tasks.length > 0) {
				for (const task of plan.tasks) {
					if (task.task_id === taskId || task._id?.toString() === taskId) {
						task.completed = typeof completed === 'boolean' ? completed : !task.completed;
						taskFound = task;
						break;
					}
				}
			}
			if (taskFound) break;
		}

		if (!taskFound) {
			return res.status(404).json({ success: false, error: `Task with ID '${taskId}' not found in this course.` });
		}

		await course.save();

		// Calculate total progress
		let totalTasks = 0;
		let completedTasks = 0;
		for (const plan of course.daily_plan) {
			if (plan.tasks) {
				totalTasks += plan.tasks.length;
				completedTasks += plan.tasks.filter(t => t.completed).length;
			}
		}

		const progressPercent = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

		res.json({
			success: true,
			message: `Task '${taskId}' completion set to ${taskFound.completed}`,
			task: taskFound,
			progress: {
				totalTasks,
				completedTasks,
				progressPercent
			}
		});
	} catch (error) {
		res.status(500).json({ success: false, error: error.message });
	}
});

// Legacy Endpoint (without auth header)
app.post('/generate', async (req, res) => {
	const prompt = req.body.query;
	try {
		const result = await generateRoadmap({ prompt });
		res.json({ success: true, data: JSON.parse(result) });
	} catch (error) {
		res.status(500).json({ success: false, error: error.message });
	}
});

app.listen(PORT, () => {
	console.log(`Server running on http://localhost:${PORT}`);
});
