import { useState } from 'react';

const initialTasks = [
  { id: 1, text: 'Build a React container', done: true },
  { id: 2, text: 'Package the app with Helm', done: true },
  { id: 3, text: 'Let Argo CD deploy it', done: false },
];

export default function App() {
  const [tasks, setTasks] = useState(initialTasks);
  const [draft, setDraft] = useState('');
  const completed = tasks.filter((task) => task.done).length;

  function addTask(event) {
    event.preventDefault();
    const text = draft.trim();
    if (!text) return;
    setTasks((current) => [...current, { id: Date.now(), text, done: false }]);
    setDraft('');
  }

  function toggleTask(id) {
    setTasks((current) => current.map((task) =>
      task.id === id ? { ...task, done: !task.done } : task,
    ));
  }

  return (
    <main className="page-shell">
      <nav className="topbar" aria-label="Main navigation">
        <a className="brand" href="#home" aria-label="Orbit home">
          <span className="brand-mark">✳</span> orbit
        </a>
        <span className="environment"><span className="pulse" /> LIVE ON KUBERNETES</span>
      </nav>

      <section className="hero" id="home">
        <div className="eyebrow"><span /> YOUR TINY GITOPS PLAYGROUND</div>
        <h1>Ship small.<br /><span>Dream orbit-sized.</span></h1>
        <p className="intro">A tiny React app taking the scenic route from Git to your Kubernetes cluster.</p>

        <div className="task-card">
          <div className="card-heading">
            <div>
              <p className="card-kicker">MISSION CONTROL</p>
              <h2>Deployment checklist</h2>
            </div>
            <div className="progress-ring" aria-label={`${completed} of ${tasks.length} complete`}>
              <strong>{completed}/{tasks.length}</strong>
            </div>
          </div>

          <div className="progress-track"><span style={{ width: `${tasks.length ? (completed / tasks.length) * 100 : 0}%` }} /></div>

          <ul className="task-list">
            {tasks.map((task) => (
              <li key={task.id} className={task.done ? 'task done' : 'task'}>
                <button className="check" type="button" onClick={() => toggleTask(task.id)} aria-label={`Mark ${task.text} ${task.done ? 'incomplete' : 'complete'}`}>
                  {task.done ? '✓' : ''}
                </button>
                <span>{task.text}</span>
                {task.done && <span className="done-label">DONE</span>}
              </li>
            ))}
          </ul>

          <form className="add-form" onSubmit={addTask}>
            <label className="sr-only" htmlFor="new-task">Add a deployment task</label>
            <input id="new-task" value={draft} onChange={(event) => setDraft(event.target.value)} placeholder="Add a mission…" />
            <button type="submit" aria-label="Add task">＋</button>
          </form>
        </div>

        <div className="pipeline" aria-label="Deployment pipeline">
          <span>GIT</span><i /> <span>HELM</span><i /> <span className="pipeline-active">ARGO CD</span><i /> <span>K8S</span>
        </div>
      </section>

      <footer><span>MADE FOR THE JOURNEY</span><span>REACT · HELM · ARGO CD</span></footer>
    </main>
  );
}