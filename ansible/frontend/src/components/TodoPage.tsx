/**
 * @todo YOU HAVE TO IMPLEMENT THE DELETE AND SAVE TASK ENDPOINT, A TASK CANNOT BE UPDATED IF THE TASK NAME DID NOT CHANGE, YOU'VE TO CONTROL THE BUTTON STATE ACCORDINGLY
 */
import { Check, Delete } from '@mui/icons-material';
import { Box, Button, Container, IconButton, TextField, Typography } from '@mui/material';
import { useEffect, useState } from 'react';
import useFetch from '../hooks/useFetch.ts';
import { Task } from '../index';


const TodoPage = () => {
  const api = useFetch();
  const [tasks, setTasks] = useState<Task[]>([]);

  const handleFetchTasks = async () => setTasks(await api.get('/tasks'));

// Créé une nouvelle tache avec le nom "Nouvelle tâche" par defaut et recharge la liste de taches
  const handleCreate = async () => {
    try {
      const response = await api.post('/tasks/', { name: 'Nouvelle tâche' });
      console.log('Réponse API :', response);
  
      setTasks(await api.get('/tasks'));
    } catch (error) {
      console.error('Erreur lors de la création de la tâche :', error);
    }
  };

  // Supprime une tache et recharge la liste de taches
  const handleDelete = async (id: number) => {
    // @todo IMPLEMENT HERE : DELETE THE TASK & REFRESH ALL THE TASKS, DON'T FORGET TO ATTACH THE FUNCTION TO THE APPROPRIATE BUTTON
    await api.delete('/tasks/' + id);
    setTasks(await api.get('/tasks'));
    console.log('Task deleted');
  }

    // Modifie la valeur de task.name a chaque modification dans l'input
  const handleChange = (id: number, value: string) => {
    setTasks((prevTasks) =>
      prevTasks.map((task) =>
        task.id === id ? { ...task, name: value } : task
      )
    );
  };

  // Envoi le contenu de task dans la BDD et recharge la liste de taches
  const handleSave = async (id: number) => {
    const taskUpdate = tasks.find((task) => task.id === id);
    await api.patch('/tasks/' + id, {name: taskUpdate?.name})
  }

  useEffect(() => {
    (async () => {
      handleFetchTasks();
    })();
  }, []);

  return (
    <Container>
      <Box display="flex" justifyContent="center" mt={5}>
        <Typography variant="h2">To Doux List</Typography>
      </Box>

      <Box justifyContent="center" mt={5} flexDirection="column">
        {
          tasks.map((task) => (
            <Box display="flex" justifyContent="center" alignItems="center" mt={2} gap={1} width="100%">
              <TextField size="small" value={task.name} fullWidth sx={{ maxWidth: 350 }} onChange={(e) => handleChange(task.id, e.target.value)} onBlur={() => handleSave(task.id)}/>
              <Box>
                <IconButton color="success" disabled>
                  <Check />
                </IconButton>
                <IconButton color="error" onClick={() => {handleDelete(task.id)}}>
                  <Delete />
                </IconButton>
              </Box>
            </Box>
          ))
        }

        <Box display="flex" justifyContent="center" alignItems="center" mt={2}>
          <Button variant="outlined" onClick={() => {handleCreate()}}>Ajouter une tâche</Button>
        </Box>
      </Box>
    </Container>
  );
}

export default TodoPage;
