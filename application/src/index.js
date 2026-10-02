require('dotenv').config();
const { Client } = require('pg');
const express = require('express');

(async () => {
    const app = express()
    const port = process.env.API_PORT || 3000
    let i = 0

    app.listen(port, () => {
        console.log(`API iniciada. Escutando PORT ${port}`)
    })

    app.use((req, res, next) => {
        i++;
        next();
    })

    app.get('/health', async(req, res) =>{
        const healthcheck = {
            uptime: process.uptime(), // Tempo em segundos que a API está rodando
            status: 'OK',
            timestamp: new Date().toISOString(),
            checks: {
                database: 'UNKNOWN'
            }
        };

        try{
            const client = new Client({
                user: process.env.DB_USER,
                host: process.env.DB_HOST,
                database: process.env.DB_DATABASE,
                password: process.env.DB_PASSWORD,
                port: process.env.DB_PORT || 5432,
            });
            await client.connect();
            await client.query('SELECT 1');
            await client.end();

            healthcheck.checks.database = "OK";
            res.status(200).send(healthcheck);
        } catch(e){
            healthcheck.status = 'ERRO';
            healthcheck.checks.database = 'ERRO';

            console.log(e);

            res.status(500).send(healthcheck);
        }
    })

    app.get('/', async (req, res) => {
        const response = { 'message': "API OK!", 'request_id': i }
        console.log(response)
        res.send(response)
    })

    app.get('/connect', async (req, res) => {
        try {
            const client = new Client({
                user: process.env.DB_USER,
                host: process.env.DB_HOST,
                database: process.env.DB_DATABASE,
                password: process.env.DB_PASSWORD,
                port: process.env.DB_PORT || 5432,
            })
            await client.connect()

            const result = await client.query('SELECT version()')
            const version = result.rows[0].version

            // Quem conectou!!
            const who = await client.query('SELECT current_user, current_database()')
            console.log(who.rows[0])
            
            await client.end()
            
            const response = { 'message': "Conectado ao banco", 'version': version, 'request_id': i }
            console.log(response)
            res.send(response)
        } catch (e) {
            const error = { 'message': 'Erro ao se conectar ao banco', 'request_id': i }
            console.log(error)
            console.log(e)

            res.status(500);
            res.send(error)
        }
    })
})()
