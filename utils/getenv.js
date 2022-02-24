module.exports = function(network) {
    // Importa variáveis de ambiente de acordo com o network selecionado
    const path = require('path')

    // [TODO] Verificar se ambiente não precisa de dotenv

    // Prestar atenção no caminho!
    const filename = network ? `./.env.${network}` : './.env'
    const envpath = path.resolve(process.cwd(), filename)
    require('dotenv').config({ path: envpath })

    return process.env
}